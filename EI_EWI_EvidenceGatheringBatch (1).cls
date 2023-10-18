global class EI_EWI_EvidenceGatheringBatch implements Database.Batchable<sObject>, database.AllowsCallouts, Database.Stateful, Schedulable {
    
    public EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
    public Map<Id,Case> mapCase = new Map<Id, Case>();
    public Map<Id, String> mapKey = new Map <Id, string>();
    
    public void execute(SchedulableContext SC){
        Database.executeBatch(new EI_EWI_EvidenceGatheringBatch(), 1);
    }

    public static List<Holiday> holidayList;
    public Date check_5_workingdaycompleted = CalculateWorkingDaysUtility.calculateWorkingDaysBetweenTwoDates(System.today(), 4);
    public Date check_10_workingdaycompleted = System.today();
     global Database.QueryLocator start(Database.BatchableContext BC){
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute EW Insured').getRecordTypeId();
         string query ='Select Id,Status,Respond_date__c,OwnerId,Previous_owner__c,AGLL_Respond_Evidance_Gathering__c,	TT_respond_evidence_gathering__c,Counter__c from Case where Respond_date__c !=null AND   RecordtypeId=:devRecordTypeId  AND (Status In (\'Evidence gathering agent/landlord\',\'Evidence gathering tenant\'))  ' ; 
         //string query ='Select Id,Status,Respond_date__c,OwnerId,Previous_owner__c,AGLL_Respond_Evidance_Gathering__c,	TT_respond_evidence_gathering__c,Counter__c from Case where Respond_date__c !=null AND   RecordtypeId=:devRecordTypeId  ' ; //AND Respond_Date__c < TODAY


         return database.getQueryLocator(query);
      }
    
    global void execute(Database.BatchableContext BC, List<Case> CaseRec){
      //  system.debug('line-->20' + CaseRec);
        Map<Id,case> evidenceGatheringNoResponceAGLLList = New Map<Id,case> ();
        Map<Id,case> evidenceGatheringResponseDoneList = New Map<Id,case> ();
       // list<case> selfResawatingreviewlist =  New list<case> ();
        Date updateresponddate = eI_EWI_DepositAllocationProposalCls.calculateWorkingDaysBetweenTwoDates(System.today(), 10); 
        if(!CaseRec.isempty()){
            For(Case caseobj : CaseRec){

                
                if(caseobj.Status=='Evidence gathering agent/landlord' && caseobj.Respond_Date__c < System.today() && caseobj.AGLL_Respond_Evidance_Gathering__c == false){    
                    caseobj.No_agent_landlord_evidence__c = true;
                    caseobj.Status='Awaiting review';    
                    evidenceGatheringNoResponceAGLLList.put(caseobj.Id,caseobj);
                }
                if(caseobj.Status=='Evidence gathering tenant' && caseobj.Respond_Date__c < System.today() && caseobj.TT_respond_evidence_gathering__c == false){    
                    caseobj.No_Tenant_Evidence__c = true;
                    caseobj.Status='Awaiting review';    
                    evidenceGatheringNoResponceAGLLList.put(caseobj.Id,caseobj);
                }
                // after deadline expire case status moves from Evidence gathering AGLL to Evidence gathering TT
                if(caseobj.Status=='Evidence gathering agent/landlord' && caseobj.Respond_Date__c < System.today() && caseobj.AGLL_Respond_Evidance_Gathering__c == true){    
                    caseobj.Status='Evidence gathering tenant';
                    caseobj.Respond_Date__c = updateresponddate;
                    evidenceGatheringResponseDoneList.put(caseobj.Id,caseobj);
                   if(!Test.isRunningTest()){
                       //EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
                       mapCase.put(caseObj.Id, caseObj);
                       mapKey.put(caseObj.Id, 'Evidence gathering tenant');
                    // EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper(caseObj, 'Evidence gathering tenant');
                    // helper.sendMailJetEmail(wrapper);    
                    }	
                    
                }
                // after deadline expire case status moves from Evidence gathering TT to Awaiting review
                if(caseobj.Status=='Evidence gathering tenant' && caseobj.Respond_Date__c < System.today() && caseobj.TT_respond_evidence_gathering__c == true){    
                    caseobj.Status='Awaiting review';    
                    evidenceGatheringResponseDoneList.put(caseobj.Id,caseobj);
                }
                
                if(caseObj.Status == 'Evidence gathering agent/landlord' && caseObj.Respond_Date__c == check_5_workingdaycompleted){
                    system.debug('Inside-->'+check_5_workingdaycompleted);
                    //EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
                    mapCase.put(caseObj.Id, caseObj);
                    mapKey.put(caseObj.Id, 'EI_EWI_EvidenceGatheringBatchforAGLL');
                    // EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper(caseObj, 'EI_EWI_EvidenceGatheringBatchforAGLL');
                    // helper.sendMailJetEmail(wrapper);
                }
                else if(caseObj.Status == 'Evidence gathering tenant' && caseObj.Respond_Date__c == check_5_workingdaycompleted){
                    //EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
                    mapCase.put(caseObj.Id, caseObj);
                    mapKey.put(caseObj.Id, 'EI_EWI_EvidenceGatheringBatchforTTNew');
                    // EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper(caseObj, 'EI_EWI_EvidenceGatheringBatchforTTNew');
                    // helper.sendMailJetEmail(wrapper);
                }

             }
            
         //   System.debug('evidenceGatheringNoResponceAGLLList => ' + evidenceGatheringNoResponceAGLLList);
            if(!evidenceGatheringNoResponceAGLLList.isempty()){ 
            Database.update(evidenceGatheringNoResponceAGLLList.values());
            }    
            
        //    System.debug('evidenceGatheringResponseDoneList => ' + evidenceGatheringResponseDoneList);
            if(!evidenceGatheringResponseDoneList.isempty()){ 
                Database.update(evidenceGatheringResponseDoneList.values());
            }        
        }  
     }
    
    
    global void finish(Database.BatchableContext BC) {
        if(!mapCase.isEmpty() && !mapKey.isEmpty()){
            EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper(mapCase, mapKey);
            helper.sendMailJetEmail(wrapper);
        }
    }
    public static Integer calculateWorkingDays(Date startDate, Date endDate)
    { 
        
        //List<Holiday> holidays=[Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        List<Holiday> holidays = eI_EWI_DepositAllocationProposalCls.listOfHolidayCountryWise('England and Wales');
        if(startDate != endDate)
        {
            Integer noOfDaysBetween = integer.valueOf(math.abs(startDate.daysBetween(endDate)));
            Integer allWorkingDays=0;
            
            for(Integer i=0;i<=noOfDaysBetween;i++) {
                if(checkifItisWorkingDay(startDate.addDays(i),holidays)) {
                    allWorkingDays++;
                }
            }
            return allWorkingDays;
        }
        else 
        {
            if(checkifItisWorkingDay(startDate,holidays)) {
                return 1;
            }
            else
            {
                return 0;
            }
            
        }
        
    }
    
    public static boolean checkifItisWorkingDay(Date currentDate, List<Holiday> holidays)
    {

        Date weekStart  = currentDate.toStartofWeek();
        Time timeflag  = Time.newInstance(0, 0, 0, 0);
        datetime currentdatetime = DateTime.newInstance(currentDate,timeflag);
        for(Holiday hDay:holidays){
            if(currentDate.daysBetween(hDay.ActivityDate) == 0){
                return false;
            }
        }
        if( currentdatetime.format('EEEE').toLowercase() =='sunday' || currentdatetime.format('EEEE').toLowercase() =='Saturday')
        {
            return false;
        }
        else
        {
           return true; 
        } 
    }
    
    
    

}