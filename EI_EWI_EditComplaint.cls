public  without sharing class EI_EWI_EditComplaint {
    
    @AuraEnabled
    public static ComplaintContactListWrapper getComplaintRecord(Id complaintId){
        //system.debug('the case is'+complaintId);
        try{
            ComplaintContactListWrapper accWrapper = new ComplaintContactListWrapper();
            Set<Id>conId = new Set<Id>();
            Set<Id> caseId = new Set<Id>();
            List<Complaint__c> compList = [select Id,Case__c,Case__r.CaseNumber,Date_complaint_received__c,Complaint_raised_by__c, Complaint_raised_by__r.Contact__r.Name,Assign_case_to__c from Complaint__c where Id=:complaintId];        
            //system.debug('the value in complaint'+compList);
            
          //  List<User> userList = [select Id,Name from User]; 
            List<PermissionSetAssignment> userList =[SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE PermissionSet.Name IN ('EWI_Lead_Adjudicator','EWI_Adjudication_Manager')];
            List<PermissionSetAssignment> UserToSend = new List<PermissionSetAssignment>();
            for(Integer i=0; i<userList.size(); i++){
                if(userList[i].AssigneeId == compList[0].Assign_case_to__c){
                    if(UserToSend.size() > 0){
                        PermissionSetAssignment tempCon = UserToSend[0];           
                        UserToSend[0] = userList[i];
                        UserToSend.add(tempCon);
                    }else{
                        UserToSend.add(userList[i]);
                    }
                }else{
                    UserToSend.add(userList[i]);
                }
            }
            
            
            List<Case_Participant__c> caseList = [select Id,Contact__c,Contact__r.Name,Case__c,Participant_name__c,First_Name__c,Last_Name__c,Case__r.Id,Case__r.CaseNumber from
                                                  Case_Participant__c where Case__c=:compList[0].Case__c];        
            // system.debug('Line no 18'+caseList);        
            
            for(Case_Participant__c objCasePart:caseList){
                conId.add(objCasePart.Contact__c);            
            }        
            List<Contact>ConList =[Select Id,Name from Contact where Id=:conId];
            
            system.debug('Line no 27'+ConList);
            List<Contact> ConListToSend = new List<Contact>();
            for(Integer i=0; i<ConList.size(); i++){
                if(ConList[i].Id == compList[0].Complaint_raised_by__r.Contact__c){
                    if(ConListToSend.size() > 0){
                        Contact tempCon = ConListToSend[0];    
                        ConListToSend[0] = ConList[i];
                        ConListToSend.add(tempCon);
                    }else{
                        ConListToSend.add(ConList[i]);
                    }
                }else{
                    ConListToSend.add(ConList[i]);
                }
            }
            
            if(!compList.isEmpty()){
                accWrapper.accRecord = compList[0];       
                accWrapper.uList = UserToSend;
                accWrapper.contactList = ConListToSend;
                accWrapper.ParticipantList = caseList;
            }
            return accWrapper;
        }
        catch(exception e){
            System.debug('ERROR => ' +  e.getMessage() + e.getLineNumber());
            return null;
        }
    }
    
    //@AuraEnabled
    public class ComplaintContactListWrapper{
        @AuraEnabled
        public Complaint__c accRecord{get;set;}         
        @AuraEnabled
        public List<PermissionSetAssignment>uList{get;set;}
        @AuraEnabled
        public List<Contact>contactList{get;set;}  
        @AuraEnabled
        public List<Case_Participant__c>ParticipantList{get;set;}
    }
    
    @AuraEnabled
    public static String editComplaint(Id accName,String cNumber,date dateCmp,Id conName,Id userName){  
        
        
        List<Case_Participant__c> casePar =[select id, Contact__c from Case_Participant__c where Id=:conName];    
        If(!String.isBlank(accName)) {
            
            Complaint__c objAccCompl = new Complaint__c();
            objAccCompl.Id = accName;                      
            objAccCompl.Date_complaint_received__c = dateCmp;           
            objAccCompl.Complaint_raised_by__c = casePar[0].Id;           
            objAccCompl.Assign_case_to__c = userName;        
            update objAccCompl;            
            return 'Case closed' + objAccCompl.Id;            
        }
        else{  
            return 'Case not closed';   
        }
    
}
     
}