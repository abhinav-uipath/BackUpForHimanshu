public Without sharing class EI_EWI_CreateAdjudicationReportRecordCls {
  @AuraEnabled
    public static List<Case> getCaseRecord(String caseId) {
        return [Select Id, Status, No_Landlord_Evidence__c,No_agent_landlord_evidence__c, No_Tenant_Evidence__c ,(select Id from Adjudication_Reports__r ) from Case where Id=:caseId limit 1];
    }
    
     @AuraEnabled
    public static User checkProfile() {        
        try {
            User loggedInUser = [SELECT Id, ProfileId,profile.name,User_Type__c, Contact.Account.IsPersonAccount
                                 FROM USER
                                 WHERE Id = :UserInfo.getUserId()];
            return loggedInUser;
            
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String createAdjReportRec (String caseId, String decisionType) 
    {
        
        List<Case> cs = [Select Id, Total_amount_in_dispute__c,No_agent_landlord_evidence__c,Deposit_Account_Number__r.Customer_Record_Type__c,
                         Dispute_Initiated_By__c,Response_Initiated_By__c, No_Tenant_Evidence__c, (Select Id, Name, Dispute_Amount__c, Type__c from Dispute_Items__r) 
                         from Case where Id =: caseId limit 1];
        Id devRecordTypeId = Schema.SObjectType.Adjudication_Report__c.getRecordTypeInfosByName().get('EWI Adjudication Report').getRecordTypeId();
        
        Adjudication_Report__c adjRepRecord = new Adjudication_Report__c();
        List<Adjudication_Report_Item__c> adjReportItems = new List<Adjudication_Report_Item__c>();
        List<Adjudication_Report_Item__c> adjReportItems2 = new List<Adjudication_Report_Item__c>();
        
        //set<Adjudication_Report_Item__c> newset = new set<Adjudication_Report_Item__c>();
        if(!cs.isEmpty()) 
        {
            
            if(decisionType =='Adjudication'){
                adjRepRecord = new Adjudication_Report__c();  
                adjRepRecord.Dispute__c = caseId;
                adjRepRecord.Statement__c = System.Label.EWI_Adjudication_statement+' '+'<a href="'+System.Label.EWI_AdjDocumentLink+'"> here.</a>';
                adjRepRecord.Status__c = 'Draft';
                adjRepRecord.Decision_Type__c = decisionType;
                adjRepRecord.RecordTypeId =devRecordTypeId;
                if((cs[0].Dispute_Initiated_By__c =='Agent' || cs[0].Response_Initiated_By__c=='Agent') 
                 //  && cs[0].Deposit_Account_Number__r.Customer_Record_Type__c=='EWI_Agent' && cs[0].No_agent_landlord_evidence__c==false)
                   && cs[0].Deposit_Account_Number__r.Customer_Record_Type__c=='EWI_Member' && cs[0].No_agent_landlord_evidence__c==false)  
                {
                        adjRepRecord.Is_Adj_Feedback_Required__c= true; 
                }
                
                /* Inserting adjudication report record */
                try { 
                    insert adjRepRecord;
                } catch(Exception e) {
                    String strError = 'The following exception has occurred: '+e.getMessage();
                    System.debug('The following exception has occurred: ' + e.getMessage());
                    return strError;
                }
                
                System.debug('Line 18 -> '+adjRepRecord.Id+' '+adjRepRecord);
                if(adjRepRecord.Id!=null) {
                    Id ARRecordTypeId = Schema.SObjectType.Adjudication_Report_Item__c.getRecordTypeInfosByName().get('EWI Adjudication Item').getRecordTypeId();
                    
                    
                    
                    for(Dispute_Item__c disItem :  cs[0].Dispute_Items__r)
                    {System.debug('Line 24 -> '+disItem.Id+' '+disItem);
                     Adjudication_Report_Item__c adjRepItem = new Adjudication_Report_Item__c();   
                     
                     if(disItem.Dispute_Amount__c > 0 && disItem.Type__c == 'Cleaning' )
                     {
                         adjRepItem.Type__c = 'Cleaning' ;
                         adjRepItem.Adjudication_Report__c = adjRepRecord.Id; 
                         adjRepItem.Dispute_Item__c = disItem.Id;
                         adjRepItem.Disputed_Amount__c = disItem.Dispute_Amount__c;
                         adjRepItem.RecordTypeId =ARRecordTypeId;
                         adjReportItems.add(adjRepItem);
                     }
                     if(disItem.Dispute_Amount__c > 0 && disItem.Type__c == 'Damage' )
                     {
                         adjRepItem.Type__c = 'Damage' ;
                         adjRepItem.Adjudication_Report__c = adjRepRecord.Id; 
                         adjRepItem.Dispute_Item__c = disItem.Id;
                         adjRepItem.Disputed_Amount__c = disItem.Dispute_Amount__c;
                         adjRepItem.RecordTypeId =ARRecordTypeId;
                         adjReportItems.add(adjRepItem);
                     }
                     if(disItem.Dispute_Amount__c > 0 && disItem.Type__c == 'Gardening' )
                     {
                         adjRepItem.Type__c = 'Gardening' ;
                         adjRepItem.Adjudication_Report__c = adjRepRecord.Id; 
                         adjRepItem.Dispute_Item__c = disItem.Id;
                         adjRepItem.Disputed_Amount__c = disItem.Dispute_Amount__c;
                         adjRepItem.RecordTypeId =ARRecordTypeId;
                         adjReportItems.add(adjRepItem);
                     }
                     if(disItem.Dispute_Amount__c > 0 && disItem.Type__c == 'Rent' )
                     {
                         adjRepItem.Type__c = 'Rent' ;
                         adjRepItem.Adjudication_Report__c = adjRepRecord.Id; 
                         adjRepItem.Dispute_Item__c = disItem.Id;
                         adjRepItem.Disputed_Amount__c = disItem.Dispute_Amount__c;
                         adjRepItem.RecordTypeId =ARRecordTypeId;
                         adjReportItems.add(adjRepItem);
                     }
                     if(disItem.Dispute_Amount__c > 0 && disItem.Type__c == 'Redecoration' )
                     {
                         adjRepItem.Type__c = 'Redecoration' ;
                         adjRepItem.Adjudication_Report__c = adjRepRecord.Id; 
                         adjRepItem.Dispute_Item__c = disItem.Id;
                         adjRepItem.Disputed_Amount__c = disItem.Dispute_Amount__c;
                         adjRepItem.RecordTypeId =ARRecordTypeId;
                         adjReportItems.add(adjRepItem);
                     }
                     if(disItem.Dispute_Amount__c > 0 && disItem.Type__c == 'Other' )
                     {
                         adjRepItem.Type__c = 'Other' ;
                         adjRepItem.Adjudication_Report__c = adjRepRecord.Id; 
                         adjRepItem.Dispute_Item__c = disItem.Id;
                         adjRepItem.Disputed_Amount__c = disItem.Dispute_Amount__c;
                         adjRepItem.RecordTypeId =ARRecordTypeId;
                         adjReportItems.add(adjRepItem);
                     }
                     
                     
                    }
                    System.debug('Line 71 -> '+adjReportItems);
                    
                    if(!adjReportItems.isEmpty())
                    {
                        insert adjReportItems;
                    }   
                }  
            }
            else if(decisionType =='Default'){
                if(cs[0].No_agent_landlord_evidence__c ==true){
                    adjRepRecord = new Adjudication_Report__c();  
                    adjRepRecord.Amended_amount_to_tenant__c = cs[0].Total_amount_in_dispute__c;
                    adjRepRecord.Dispute__c = caseId;
                    adjRepRecord.Statement__c = System.Label.EWI_No_AGLL_evidence_statement;   
                    adjRepRecord.Status__c = 'Draft';
                    adjRepRecord.Decision_Type__c = decisionType;
                    adjRepRecord.RecordTypeId =devRecordTypeId;
                    if((cs[0].Dispute_Initiated_By__c =='Agent' || cs[0].Response_Initiated_By__c=='Agent') 
                       && cs[0].Deposit_Account_Number__r.Customer_Record_Type__c=='EWI_Member' && cs[0].No_agent_landlord_evidence__c==false)
                    {
                        adjRepRecord.Is_Adj_Feedback_Required__c= true; 
                    }
                    
                    /* Inserting adjudication report record */
                    try { 
                        insert adjRepRecord;
                    } catch(Exception e) {
                        String strError = 'The following exception has occurred: '+e.getMessage();
                        System.debug('The following exception has occurred: ' + e.getMessage());
                        return strError;
                    }
                }
                if(cs[0].No_Tenant_Evidence__c ==true){
                    adjRepRecord = new Adjudication_Report__c();  
                    adjRepRecord.Amended_amount_to_AGLL__c =cs[0].Total_amount_in_dispute__c; 
                    adjRepRecord.Dispute__c = caseId;
                    adjRepRecord.Statement__c = System.Label.EWI_No_TT_evidence_statement;
                    adjRepRecord.Status__c = 'Draft';
                    adjRepRecord.Decision_Type__c = decisionType;
                    adjRepRecord.RecordTypeId =devRecordTypeId;
                    
                    /* Inserting adjudication report record */
                    try { 
                        insert adjRepRecord;
                    } catch(Exception e) {
                        String strError = 'The following exception has occurred: '+e.getMessage();
                        System.debug('The following exception has occurred: ' + e.getMessage());
                        return strError;
                    }   
                }
            }
        }
        cs[0].Total_Claim_Amount__c = cs[0].Total_amount_in_dispute__c;
        update cs[0];
        
        return adjRepRecord.Id; 
    }
    

}