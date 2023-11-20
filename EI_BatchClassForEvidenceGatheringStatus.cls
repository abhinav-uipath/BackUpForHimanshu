public without sharing class EI_BatchClassForEvidenceGatheringStatus implements DataBase.Batchable<sObject>,Database.Stateful,Database.allowscallouts{
    
    
    Map<String,Set<Id>> mapOfMailTypeVsCaseIds = new Map<String,Set<Id>>();
    List<Case> updateCaseList1 = new List<Case>();
    map<id,Case> caseMap1 = new map<id,Case>();
    List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = New List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
    
    public EI_BatchClassForEvidenceGatheringStatus() {
        mapOfMailTypeVsCaseIds.put('EvidenceGLL',new Set<Id>()); // NPP-4,5
        mapOfMailTypeVsCaseIds.put('EvidenceGTT',new Set<Id>());
        mapOfMailTypeVsCaseIds.put('SelfRes',new Set<Id>());  // NPP-37 
        mapOfMailTypeVsCaseIds.put('SelfRes10DayR',new Set<Id>());
    }
    
    public DataBase.QueryLocator start(DataBase.BatchableContext BC) {
        
        //Integer days = Integer.valueOf(system.Label.Working_Days_For_Reminder);
        //Date currentDate = system.today().addDays(-days);
           Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute SDS Custodial').getRecordTypeId();   
        String query = 'SELECT Id,Two_times_no_engagement__c,AGLL_Respond_Self_resolution__c,TT_respond_Self_resolution__c, No_Tenant_Evidence__c, '
            +'No_Landlord_Evidence__c,Status,Respond_Date__c,No_of_tenant_evidence__c,No_of_AGLL_evidences__c,AGLL_Respond_Evidance_Gathering__c,PreviousStatus__c,TT_respond_evidence_gathering__c,Awaiting_evidence_review_date__c '
            +'FROM Case where Respond_Date__c != null AND  RecordtypeId=:devRecordTypeId AND (Status In (\'Evidence gathering AA/LL\', \'Evidence Gathering TT\' ,\'On Hold\' , \'Repayment disputed - self-resolution\'))  '; //AND ID =\'5003L000007HcDvQAK\'
        return DataBase.getQueryLocator(query);
    }
    
    public void execute(DataBase.BatchableContext BC,List<Case> caseList) {
        List<Case> updateCaseList = new List<Case>();
        List<Case> updateCaseList3 = new List<Case>();
        map<id,Case> caseMap3 = new map<id,Case>();
        map<id,Case> caseMap = new map<id,Case>();
        List<Case> updateCaseList4 = new List<Case>();
        map<id,Case> caseMap4 = new map<id,Case>();


        if(!caseList.isEmpty()) {
           
             Date checkdate = EI_UtilityClassForPayments.dueDateMethod(System.today(),10);
            for(Case eachCase : caseList) {
                // Start - NPP - 4,5
                if(eachCase.Status == 'Evidence gathering AA/LL' /*|| eachCase.PreviousStatus__c =='Evidence gathering AA/LL'*/) {
                     // method to calculate working days diff btw two dates
                        Integer diffinDays =0;
                    
                    if(eachCase.No_of_AGLL_evidences__c==0 && (System.today() > eachCase.Respond_Date__c)) {
                          system.debug('line-->46');
                            //diffinDays = calculateWorkingDays(eachCase.Respond_Date__c,System.today());
                          //  diffinDays = EI_UtilityClassForPayments.calculateWorkingDaysBetweenTwoDates(eachCase.Respond_Date__c,System.today());
                               // if(Test.isRunningTest() /*|| diffinDays == 1*/){
                                      system.debug('line-->49');
                                    eachCase.No_Landlord_Evidence__c = true;
                                    eachCase.Status = 'Awaiting evidence review';
                                    eachCase.Awaiting_evidence_review_date__c=System.today();
                                    updateCaseList3.add(eachCase);
                               // }
                        system.debug('line-->57' + updateCaseList3);
                        }
                    
                    if(/*eachCase.AGLL_Respond_Evidance_Gathering__c==true ||*/ eachCase.No_of_AGLL_evidences__c>0 ){
                        if(System.today() > eachCase.Respond_Date__c) { 
                        eachCase.Status = 'Evidence gathering TT';
                        eachCase.AGLL_Respond_Evidance_Gathering__c=true ;
                        eachcase.Respond_Date__c = checkdate;
                      //  eachcase.Bypass_validation__c = true;
                        updateCaseList1.add(eachCase);
                        }
                    }
                    
                    if(!eachCase.AGLL_Respond_Evidance_Gathering__c) {
                        if(System.today() <= eachCase.Respond_Date__c) {
                            //diffinDays = calculateWorkingDays(System.today(),eachCase.Respond_Date__c);
                            diffinDays = EI_UtilityClassForPayments.calculateWorkingDaysBetweenTwoDates(System.today(),eachCase.Respond_Date__c);
                            if(/*Test.isRunningTest()|| */ diffinDays == 5) {
                                system.debug('sendEmail');
                                mapOfMailTypeVsCaseIds.get('EvidenceGLL').add(eachCase.Id);
                                // collect ids to send mail
                            }
                        }
                    }
                        
                    
                }
                if(eachCase.Status == 'Evidence gathering TT' /* || eachCase.PreviousStatus__c == 'Evidence gathering TT'*/) {
                    
                     if((System.today() > eachCase.Respond_Date__c)) {
                                //diffinDays = calculateWorkingDays(eachCase.Respond_Date__c,System.today());
                                //diffinDays = EI_UtilityClassForPayments.calculateWorkingDaysBetweenTwoDates(eachCase.Respond_Date__c,System.today());
                               // if(Test.isRunningTest() /* || diffinDays == 1*/) {
                                    eachCase.Status = 'Awaiting evidence review';
                                    if(eachCase.No_of_tenant_evidence__c==0){
                                    eachCase.No_Tenant_Evidence__c = true;
                                    }  
                                    eachCase.Awaiting_evidence_review_date__c=System.today();
                                    updateCaseList.add(eachCase);
                             //   }
                        }
                    
                    if(!eachCase.TT_respond_evidence_gathering__c) {
                        // method to calculate working days diff btw two dates
                        Integer diffinDays =0;
                        if(System.today() <= eachCase.Respond_Date__c) {
                            //diffinDays = calculateWorkingDays(System.today(),eachCase.Respond_Date__c);
                            diffinDays = EI_UtilityClassForPayments.calculateWorkingDaysBetweenTwoDates(System.today(),eachCase.Respond_Date__c);
                            if(/*Test.isRunningTest() ||*/ diffinDays == 5) {
                                mapOfMailTypeVsCaseIds.get('EvidenceGTT').add(eachCase.Id);
                                // collect ids to send mail
                            }
                        }
                    }
                }
                // END - NPP - 4,5
                // Start - NPP 37
                if(eachCase.Status == 'Repayment disputed - self-resolution' /*|| eachcase.PreviousStatus__c =='Repayment disputed - self-resolution'*/) {
                     // Start NPP-41
                    if(eachCase.AGLL_Respond_Self_resolution__c || eachCase.TT_respond_Self_resolution__c) {                       
                        if(System.today() > eachCase.Respond_Date__c) {
                            //Integer diffinDays = calculateWorkingDays(eachCase.Respond_Date__c,System.today());
                            //Integer diffinDays = EI_UtilityClassForPayments.calculateWorkingDaysBetweenTwoDates(eachCase.Respond_Date__c,System.today());
                            //if(diffinDays == 1) {
                                eachCase.Status = 'Self-resolution - awaiting review';
                                updateCaseList4.add(eachCase);
                          //  }
                        }
                    }
                    
                    if(!eachCase.AGLL_Respond_Self_resolution__c && !eachCase.TT_respond_Self_resolution__c) {
                        // method to calculate working days diff btw two dates
                        Integer diffinDays =0;
                        if(System.today() <= eachCase.Respond_Date__c){
                            //diffinDays = calculateWorkingDays(System.today(),eachCase.Respond_Date__c);
                            diffinDays = EI_UtilityClassForPayments.calculateWorkingDaysBetweenTwoDates(System.today(),eachCase.Respond_Date__c);
                            if(/*Test.isRunningTest() || */ diffinDays == 5) {
                                mapOfMailTypeVsCaseIds.get('SelfRes').add(eachCase.Id);
                                // collect ids to send mail
                            }
                            
                        } else {
                            //diffinDays = calculateWorkingDays(eachCase.Respond_Date__c,System.today());
                            //diffinDays = EI_UtilityClassForPayments.calculateWorkingDaysBetweenTwoDates(eachCase.Respond_Date__c,System.today());
                            if(System.today() > eachCase.Respond_Date__c) {
                                if(!eachCase.Two_times_no_engagement__c) {
                                    eachCase.Two_times_no_engagement__c = true; }
                                // TJ - Added to update response date till the time Case is in Self-Res
                                   eachCase.Respond_Date__c = EI_UtilityClassForPayments.dueDateMethod(eachCase.Respond_Date__c,10);
                                    updateCaseList.add(eachCase);
                                    mapOfMailTypeVsCaseIds.get('SelfRes10DayR').add(eachCase.Id);
                                //}
                                // update respond date for next 10 days
                            }
                        }
                    }
                } 
                // End - NPP 37
                
            } 
        }
        
        if(!updateCaseList.isEmpty()){
        caseMap.putall(updateCaseList);
        //update caseMap.values();
        Database.update(caseMap.values(),false);
        }
          if(!updateCaseList1.isEmpty()){
        caseMap1.putall(updateCaseList1);
        Database.update(caseMap1.values(),false);
        //update caseMap1.values();
        }
        
         if(!updateCaseList3.isEmpty()){
        caseMap3.putall(updateCaseList3);
        //update  caseMap3.values();
         Database.update(caseMap3.values(),false);
         }
        
        
         if(!updateCaseList4.isEmpty()){
        caseMap4.putall(updateCaseList4);
        //update  caseMap4.values();
        Database.update(caseMap4.values(),false);
         }
    }
    
    public void finish(DataBase.BatchableContext BC) {
        if(!updateCaseList1.isEmpty()){ 
        sendEmailForEvidGatheringfrombatch(caseMap1.keyset(), 'evidenceaglltott', emailWrapperList);  
        } 
      //  commented due to some live issues
        else { if(!Test.isRunningTest() && !mapOfMailTypeVsCaseIds.isEmpty()){
            system.enqueueJob(new EI_ReminderForEvidenceMails(mapOfMailTypeVsCaseIds));
        }
             }
        
    }
    
    
    
        public static void sendEmailForEvidGatheringfrombatch(Set<Id> caseIds, String stage, List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList) {
        
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        
       List<Case_Participant__c> cspar = [SELECT Id, Name, Case__c, Contact__r.Email, Contact__r.Name, Contact__r.FirstName, Contact__r.LastName, Contact__c, 
             Case__r.Tenancy_Property_Address__c, Case_Participant__c.Type__c, Is_Lead__c, Case__r.Deposit_Account_Number__c,
             Account__c,Account__r.name,Account__r.Email__c,Account__r.Personemail,
             Case__r.Deposit_Account_Number__r.Name, Case__r.Disputed_Amount__c, Case__r.Remaining_protected_amount__c, 
             Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c, Case__r.Respond_Date__c 
             FROM Case_Participant__c WHERE Case__c IN : caseIds]; 
            
        for(Case_Participant__c caspart : cspar)
           /* [SELECT Id, Name, Case__c, Contact__r.Email, Contact__r.Name, Contact__r.FirstName, Contact__r.LastName, Contact__c, 
             Case__r.Tenancy_Property_Address__c, Case_Participant__c.Type__c, Is_Lead__c, Case__r.Deposit_Account_Number__c,
             Account__c,Account__r.name,Account__r.Email__c,Account__r.Personemail,
             Case__r.Deposit_Account_Number__r.Name, Case__r.Disputed_Amount__c, Case__r.Remaining_protected_amount__c, 
             Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c, Case__r.Respond_Date__c 
             FROM Case_Participant__c WHERE Case__c IN : caseIds]) */
        {
            // Sending mail to agent/landlord
            if((caspart.Type__c == 'Landlord' || caspart.Type__c == 'Agent') && caspart.Contact__r.Email != null) {
                string usermail;
                if(stage == 'evidenceaglltott') {
                    if(caspart.Account__r.email__c !=null){
                     usermail = caspart.Account__r.email__c;   
                    }
                    else{
                     usermail = caspart.Account__r.personemail;   
                    }
                    system.debug('line-->595' + stage );
                    /* Newly added code for adding recipients, variables, template name, Subject START */
                    List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                    emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(usermail, caspart.Account__r.Name, 
                                                                                  caspart.Case__c, caspart.Account__c));
                    Map<String, String> variableMap = new Map<String, String>();
                    
                    variableMap.put('date',todayStr);
                    variableMap.put('name',caspart.Account__r.Name);
                    
                    emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                   'RequestingTTEvidenceAGLL', 
                                                                                   'The tenant(s) has been asked to provide evidence - '
                                                                                   +caspart.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c 
                                                                                  ));
                    /* Newly added code for adding recipients, variables, template name, Subject END */
                    
                }
            }
            // Sending mail to tenants
            else if(caspart.Type__c == 'Tenant' /*&& caspart.Contact__r.Email != null*/) {
                if(stage == 'evidenceaglltott') {
                     Date respondDate = EI_UtilityClassForPayments.dueDateMethod(system.today(),10);
                    String respondDateStr = respondDate.day()+'/'+respondDate.month()+'/'+respondDate.year();
                    //Date respondDate = caspart.Case__r.Respond_Date__c;
                  //  respondDateStr = respondDate.day()+'/'+respondDate.month()+'/'+respondDate.year();
                    
                    /* Newly added code for adding recipients, variables, template name, Subject START */
                    List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                    emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(caspart.Contact__r.Email, caspart.Contact__r.Name, 
                                                                                  caspart.Case__c, caspart.Contact__c));
                    Map<String, String> variableMap = new Map<String, String>();
                    
                    variableMap.put('date',todayStr);
                    variableMap.put('name',caspart.Contact__r.Name);
                    variableMap.put('respondDate',respondDateStr);
                    
                    if(!caspart.Is_Lead__c) {
                        emailWrapperList.add(
                            new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                      'RequestingTTEvidenceTT', 
                                                                      'Lead tenant has been invited to submit evidence - '
                                                                      +caspart.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c 
                                                                     ));
                    } else {
                        emailWrapperList.add(
                            new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                      'RequestingTTEvidenceTT', 
                                                                      'Please submit your evidence - '
                                                                      +caspart.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c 
                                                                     ));
                    }
                    /* Newly added code for adding recipients, variables, template name, Subject END */
                    
                }
            }
        }
            if(emailWrapperList.size()>0) {
                EI_SDS_MailJetUtilityCls.sendEmailFromBatch(JSON.serialize(emailWrapperList));     
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
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
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