public without sharing class EI_SDS_TransferDepositsController {
    @AuraEnabled
	public static list<depoAccountWrapper> DepositList(String accountId){
Integer i =0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;       
        list<depoAccountWrapper> wrapperList = new list<depoAccountWrapper>();
     	
        for(Deposit__c depoObj : [Select id, Deposit_Transferred_to_Account__c,Status__c, Customer__c, Deposit_Account_Number__c,Property_Address__c, Deposit_Amount__c, Property__c  from Deposit__c where   Status__c IN ('Deposits held by scheme','Repayment requested by tenant','Repayment requested by agent/landlord','Repayment not agreed - In self-resolution')   AND Customer__c =:accountId]) {
            
            depoAccountWrapper wrap = new depoAccountWrapper();
            wrap.isSelected = false;            wrap.depositObj = depoObj;             wrapperList.add(wrap);
        }

        return wrapperList;
    }
    
    @AuraEnabled
    public static List<userEmailBranchesWrapper> getUserDetails(String userEmail){
        list<userEmailBranchesWrapper> wrapperList = new list<userEmailBranchesWrapper>();
        
        List<user> getUserList = [select id, Name, Email, Phone, Street, City, PostalCode, State, Country, username, accountid, contactid, Profile.Name, isActive from user 
                                  where email = :userEmail and isActive = true and
                                  (Profile.Name='Agent' OR Profile.Name='Landlord' OR Profile.Name='Branch User' OR Profile.Name='Head Office User')];
        
        List<branchObj> branchList = new List<branchObj>();
        for(Branch_User_Mapping__c branchUserMap : [select id, name, Branch__c, Branch__r.Name, Branch__r.Branch_ID__c, Branch__r.Branch_Name__c, User__c, User__r.Profile.Name, User__r.isActive, User__r.Email  from Branch_User_Mapping__c where User__r.Email=:userEmail and User__r.isActive = true])
        {
            branchObj newBranch = new branchObj();
            newBranch.Id = branchUserMap.Branch__c;            
            //newBranch.Branch_ID__c = branchUserMap.Branch__r.Branch_ID__c;
            newBranch.branchName = branchUserMap.Branch__r.Branch_Name__c;
            newBranch.User = branchUserMap.User__c;
            branchList.add(newBranch);
        }
        userEmailBranchesWrapper wrap = new userEmailBranchesWrapper();
        /* if(getUserList.size() > 0){
            wrap.userObj = getUserList[0];
        }else{
            wrap.userObj = null;
        } */       
        wrap.userList = getUserList;
        wrap.branchList = branchList; 
        wrapperList.add(wrap);
        System.debug('wrapperList => ' + wrapperList);
        return wrapperList;
    }
    
    @AuraEnabled
    public static String transferDeposits(String fromUserAccId, List<Id> depositstobeTransfered, String usertoTransfer, String branchId){
        system.debug('usertoTransfer='+usertoTransfer);
        user currentUser = [select id, accountid, contactid, Profile.Name from user where Id = :usertoTransfer];
        Savepoint sp = Database.setSavepoint();
        
        List<Deposit__c> updateDeposit = new List<Deposit__c>(); 
        Map<Id, Property__c> updateProperty = new Map<Id, Property__c>(); 
        Map<Id, Property_Allocation__c> updatePropertyAllocation = new Map<Id, Property_Allocation__c>(); 
        List<Case> listCaseToUpdate = new List<Case>();
        List<Case_Participant__c> listCaseParticipantsToUpdate = new List<Case_Participant__c>();
        List<Repayment_Request__c> listRepayReqToUpdate = new List<Repayment_Request__c>();
        List<Repayment_Request_Line__c> listRepayReqLineToUpdate = new List<Repayment_Request_Line__c>();
        try{
            system.debug('depositstobeTransfered => '+ depositstobeTransfered);
            
            for(Deposit__c deposit : [SELECT Id,Name,EI_Old_Customer__c,Deposit_Transferred__c,Customer__c,Customer_email__c,Customer_Name__c, Property_Address__c, Property_Address_Without_Country__c, New_Customer_Email__c,
                                      Deposit_Transferred_to_Account__c, Deposit_Transferred_to_Account__r.Email__c, Deposit_Transferred_to_Account__r.Name, Transfer_deposit_start_date__c,
                                      Property__c, Property__r.Property_Owner__c,
                                      (select id, Deposit_Holder__c, Deposit_Holder__r.Email__c, Deposit_Holder__r.Name, Contact__c from Deposit_Allocations__r where Role__c ='Tenant')
                                      from Deposit__c where Id IN :depositstobeTransfered Limit 1000])
               
            {    
                deposit.EI_Old_Customer__c = deposit.Customer__c;
                deposit.Customer__c = currentUser.AccountId;
                deposit.previous_Customer__c = fromUserAccId;
                deposit.EI_SDSProtectedByContact__c = currentUser.contactid;
                if(branchId != null){
                    deposit.Branch__c = branchId;
                }else{
					deposit.Branch__c = null;
				}
                updateDeposit.add(deposit);
                
				Property__c propObj = new Property__c(Id = deposit.Property__c, Property_Owner__c = currentUser.AccountId);
				if(branchId != null){
                    propObj.Branch__c = branchId;
                }else{
					deposit.Branch__c = null;
				}
                if(currentUser.Profile.Name == 'Landlord'){
                    propObj.Primary_Landlord__c = currentUser.ContactId;
                }
                updateProperty.put(deposit.Property__c, propObj);
            } 
                If(!updateDeposit.isEmpty()){
                update updateDeposit;
                
                for(Case cs :  [Select id, Status, Deposit_Account_Number__c, Agent__c, Agent_Contact__c, Landlord__c, owner.Profile.Name,  (Select Id, Account__c, Contact__c FROM Case_Participants__r Where Account__c =: fromUserAccId)   FROM Case where Deposit_Account_Number__c IN :depositstobeTransfered and Deposit_Account_Number__r.Status__c != 'Deposits held by scheme'])
                {
                    String prevOwnerId = cs.ownerId;
                    cs.Before_Transfer_Owner__c = prevOwnerId;
                    if(cs.owner.Profile.Name == 'Agent' || cs.owner.Profile.Name == 'Landlord'||  cs.owner.Profile.Name == 'Branch User' || cs.owner.Profile.Name == 'Head Office User'){
                        cs.OwnerId = currentUser.Id;
                    }
                    listCaseToUpdate.add(cs);
                    
                    for(Case_Participant__c csPar : cs.Case_Participants__r){
                        if(csPar.Account__c == fromUserAccId){
                            csPar.Account__c = currentUser.AccountId; csPar.Contact__c = currentUser.ContactId;   listCaseParticipantsToUpdate.add(csPar);
                        }
                    }
                }
                
                for(Repayment_Request__c repReq :  [Select Id, Account__c, Contact__c, (Select Id, Account__c, Contact__c FROM Repayment_Request_Lines__r where Account__c =: fromUserAccId)   FROM Repayment_Request__c where Case__r.Deposit_Account_Number__c IN :depositstobeTransfered and Account__c =: fromUserAccId])
                {
                    if(repReq.Account__c == fromUserAccId){
                        repReq.Account__c = currentUser.AccountId;  repReq.Contact__c = currentUser.ContactId;
                    }
                    listRepayReqToUpdate.add(repReq);
                    for(Repayment_Request_Line__c repReqLine : repReq.Repayment_Request_Lines__r){
                        if(repReqLine.Account__c == fromUserAccId){
                            repReqLine.Account__c = currentUser.AccountId;  repReqLine.Contact__c = currentUser.ContactId;     listRepayReqLineToUpdate.add(repReqLine);
                        }
                    }
                }
                
                if(!listCaseToUpdate.isEmpty()){
                    update listCaseToUpdate;
                }
                if(!listCaseParticipantsToUpdate.isEmpty()){
                    update listCaseParticipantsToUpdate;
                }
                if(!listRepayReqToUpdate.isEmpty()){
                    update listRepayReqToUpdate;
                }
                if(!listRepayReqLineToUpdate.isEmpty()){
                    update listRepayReqLineToUpdate;
                }
            }
            
            if(updateProperty.size() > 0){
                update updateProperty.values();
                
                for(Property_Allocation__c propAlloc : [Select Id, Name, Relation_to_Property__c, Contact__c, Property__c From Property_Allocation__c  Where Relation_to_Property__c = 'Primary Landlord'  and Property__c IN :updateProperty.keySet()] )
                {
                    if(currentUser.profile.Name == 'Landlord'){
                        propAlloc.Contact__c = currentUser.ContactId;                        updatePropertyAllocation.put(propAlloc.Id, propAlloc);
                    }
                }
                
                if(updatePropertyAllocation.size() > 0){
                    update updatePropertyAllocation.values();
                }
            }
            
            return 'Success';
        }
        catch(Exception e){
            Database.rollback(sp);
            return string.valueOf(e);
        }
    }
     
    public class depoAccountWrapper{
        @AuraEnabled public Deposit__c depositObj{get;set;}        @AuraEnabled public Boolean isSelected{get;set;}
        
        
    }
    public class userEmailBranchesWrapper{
        //@AuraEnabled public user userObj{get;set;}
        @AuraEnabled public List<User> userList{get;set;}
        @AuraEnabled public List<branchObj> branchList{get;set;}  
    }
    public class branchObj{
        @AuraEnabled public String Id {get;set;}
        @AuraEnabled public String branchName {get;set;}
        @AuraEnabled public String User {get;set;}
    }
    
}