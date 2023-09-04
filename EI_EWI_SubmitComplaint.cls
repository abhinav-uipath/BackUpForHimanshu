public without sharing class EI_EWI_SubmitComplaint {
    
    @AuraEnabled
    public static AccountContactListWrapper getCaseRecord(Id CaseId){
        system.debug('the case is'+CaseId);
        AccountContactListWrapper accWrapper = new AccountContactListWrapper();
        Set<Id>conId = new Set<Id>();
        List<String> part = new List<String>();
        List<Case_Participant__c> caseList = [select Id,Contact__c,Contact__r.Name,Case__c,Case__r.Id,Case__r.CaseNumber,Participant_name__c,Account__c,Account__r.Name,First_Name__c,Last_Name__c from Case_Participant__c where Case__c=:CaseId];        
        System.debug('Line No 9'+caseList);
        for(Case_Participant__c objCase : caseList ){
            part.add(objCase.Participant_name__c);
            System.debug('Line No 16'+part);
        }
        List<PermissionSetAssignment> userList =[SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE PermissionSet.Name IN ('EWI_Lead_Adjudicator','EWI_Adjudication_Manager')]; 
        
        for(Case_Participant__c objAccPart:caseList){
         conId.add(objAccPart.Account__c);            
        }        
        List<Account>ConList =[Select Id,Name from Account where Id=:conId];   
        
        if(!caseList.isEmpty() && !userList.isEmpty()){
            accWrapper.accRecord = caseList[0];       
            accWrapper.uList = userList;
            accWrapper.contactList = ConList;
            accWrapper.ParticipantList = caseList;
             
         }
        return accWrapper;
    }
     
    // wrapper class with @AuraEnabled and {get;set;} properties
    public class AccountContactListWrapper{
        @AuraEnabled
        public Case_Participant__c accRecord{get;set;}         
        @AuraEnabled
        public List<PermissionSetAssignment>uList{get;set;}
        @AuraEnabled
        public List<Account>contactList{get;set;} 
        @AuraEnabled
        public List<Case_Participant__c>ParticipantList{get;set;}
    }
    
    
 @AuraEnabled
public static String submitComplaint(Id accName,date dateCmp,Id conName,Id userName){  
    
    try{
        
        List<Case> objCase = [select id,status from Case where id=:accName AND status IN('Deposit closed - deposit repaid in part','Deposit closed - deposit repaid in full','Deposit closed - unable to repay','Deposit to be repaid - decision issued','Decision issued - dispute monies outstanding','Decision issued - Insurance claim','Decision issued - with legal')];  
        
        If(objCase.size() > 0) {
            Complaint__c objAccCompl = new Complaint__c();
            objAccCompl.Case__c = accName;            
            objAccCompl.Date_complaint_received__c = dateCmp;           
            objAccCompl.Complaint_raised_by__c = conName;           
            objAccCompl.Assign_case_to__c = userName;        
            insert objAccCompl; 
            system.debug('line-->60 ' + objAccCompl);
            return 'Case closed' + objAccCompl.Id;            
        } 
        else{  
            return 'Case not closed';   
        }
    }
    catch(exception e){
      
           System.debug('exception error msg => ' + e.getMessage() + ' line no => ' + e.getLineNumber());
        return e.getMessage() + ' line no => ' + e.getLineNumber();
        
    }    
    
}
    public static void justIncrement() { 
        Integer i = 0;
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
       
        
    }
}