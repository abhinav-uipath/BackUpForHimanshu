//	Self Resolution Batch
global class EI_EWI_SelfResolutionBatch implements Database.Batchable<sObject>, database.AllowsCallouts, Database.Stateful, Schedulable {
  
    public void execute(SchedulableContext SC){
        Database.executeBatch(new EI_EWI_SelfResolutionBatch(), 10);
    }

    
    public static List<Holiday> holidayList;
    public Date check_5_workingdaycompleted = calculateWorkingDaysBetweenTwoDates(System.today(), 4);
    public Date check_10_workingdaycompleted = System.today();
    public EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
    Public Map<Id, Case> caseMap = new Map<Id, Case>();
    Public Map<Id, String> keyMap = new Map<Id, String>();
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute EW Insured').getRecordTypeId();
        string query = 'Select Id,Status,Respond_date__c,Two_times_no_engagement__c ,OwnerId,Previous_owner__c,TDSN_Reference_Number__c,TT_respond_Self_resolution__c,AGLL_Respond_Self_resolution__c,Counter__c,Deposit_Account_Number__r.Property_Address_WO_Country__c, ' +
            '(Select Id,Type__c, Case__c,Account__c, Account__r.Name, Account__r.Email__c, Account__r.PersonEmail, Contact__c, Contact__r.Email, Contact__r.Name, Access_Code__c From Case_Participants__r  ) ' +
            'from Case where Respond_date__c !=null AND   RecordtypeId=:devRecordTypeId  AND (Status In (\'Self-resolution\', \'Self-resolution - awaiting review\') ) ';
           // 'from Case where Respond_date__c !=null AND   RecordtypeId=:devRecordTypeId  AND (Status In (\'Self-resolution\', \'Self-resolution - awaiting review\') ) AND Id= \'5003L000008BELYQA4\' ';
        // AND Id= \'5003L000008B0S2QAK\'
        return database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> CaseRec){
        system.debug('line-->11' + CaseRec );
        list<case> Resetkpiofselfresolutionlist = New list<case> ();
        list<case> selfResawatingreviewlist =  New list<case> ();
        list<case> selfResNoAgreementTwicelist = New list<case> ();
        set<id> caseids = new  set<id>();
        List<Chat_History__c> newchatlist = new List<Chat_History__c>();
        Date updateresponddate = eI_EWI_DepositAllocationProposalCls.calculateWorkingDaysBetweenTwoDates(System.today(), 10); 
        if(!CaseRec.isempty()){
            For(Case caseobj : CaseRec){
                
                //mailjetcode start code for send mail after 10 working days
                
                if(caseObj.Status == 'Self-resolution' && caseObj.Respond_Date__c < check_10_workingdaycompleted && caseobj.Counter__c ==1 && caseobj.TT_respond_Self_resolution__c == false && caseobj.AGLL_Respond_Self_resolution__c ==false){
                    system.debug('ten complete day='+check_10_workingdaycompleted);
                    caseMap.put(caseObj.Id, caseObj);
                    keyMap.put(caseObj.Id, 'selfResolutionfor10workingDayBatch');
                  
                }
                //mailjetcode end
                
                if(caseobj.Status=='Self-resolution' && caseobj.Respond_Date__c < System.today() && caseobj.Counter__c ==1 && caseobj.TT_respond_Self_resolution__c == false && caseobj.AGLL_Respond_Self_resolution__c ==false){
                    system.debug('line-->16');
                    caseobj.Counter__c = 2;
                    caseobj.Respond_Date__c = updateresponddate;
                    Resetkpiofselfresolutionlist.add(caseobj);
                    caseids.add(caseobj.Id);
                }
                if(caseobj.Status=='Self-resolution' && caseobj.Respond_Date__c < System.today() && caseobj.Counter__c ==2 && caseobj.TT_respond_Self_resolution__c == false && caseobj.AGLL_Respond_Self_resolution__c ==false){
                    // EID-1405 - Modified by TJ - to update response date after 2 cycles of self-res.
                    if(caseobj.Two_times_no_engagement__c==false){
                         caseobj.Two_times_no_engagement__c=true;
                    }
                   	caseobj.Respond_Date__c = updateresponddate;
                    selfResNoAgreementTwicelist.add(caseobj);
                }
                
                if(caseobj.Status=='Self-resolution' && caseobj.Respond_Date__c < System.today() && (caseobj.TT_respond_Self_resolution__c == true || caseobj.AGLL_Respond_Self_resolution__c ==true)){
                    caseobj.Status = 'Self-resolution - awaiting review';
                    caseobj.Previous_owner__c =  caseobj.OwnerId;
                    selfResawatingreviewlist.add(caseobj);
                }
                
                //mailjetcode start code for mail send after 5 working days
                
                system.debug('five complete day='+check_5_workingdaycompleted + 'caseObj.Respond_Date__c '+caseObj.Respond_Date__c);
                //Added by Himanshi EID-1433
                if(caseObj.Status == 'Self-resolution' && caseObj.Respond_Date__c == check_5_workingdaycompleted && (caseobj.TT_respond_Self_resolution__c == false || caseobj.AGLL_Respond_Self_resolution__c ==false)){
                    system.debug('five complete day='+check_5_workingdaycompleted);
                    caseMap.put(caseObj.Id, caseObj);
                    keyMap.put(caseObj.Id, 'selfResolutionfor5workingDayBatch');
                    
                }
                //mailjetcode end
            }
            
             If(!caseids.isempty()){
                    newchatlist = [select id,Case__c from Chat_History__c  where Case__c IN :caseids ] ;          
                }
                
                If(!newchatlist.isempty()){
                    Database.Delete(newchatlist);  
                }
                
                
                if(!Resetkpiofselfresolutionlist.isempty()){ 
                    Database.update(Resetkpiofselfresolutionlist);
                }
                
                If(!selfResawatingreviewlist.isempty()){ 
                    Database.update(selfResawatingreviewlist);
                }
                
                if(!selfResNoAgreementTwicelist.isempty()){ 
                    Database.update(selfResNoAgreementTwicelist);
                }
            
            
            
        }
    }  
    global void finish(Database.BatchableContext BC) {
        EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper();
        wrapper.keyMap = keyMap;
        wrapper.newMap = caseMap;
        system.debug('line-->104' + wrapper);
        helper.sendMailJetEmail(wrapper);
    }
    
     public static Date calculateWorkingDaysBetweenTwoDates(Date startDate, Integer noOfDays) {
        if(startDate == null) {
            return null;
        }
        if(holidayList == null || holidayList.isEmpty()) {
            holidayList = [Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        }
        
        Integer allWorkingDays=0;
        Integer totalDays = 1;
        while(allWorkingDays<=noOfDays) {
            if(checkifItisWorkingDay(startDate.addDays(totalDays),holidayList)) {
                allWorkingDays++;
                if(allWorkingDays==noOfDays)
                    break;
            }
            totalDays++;
        }
        while(!checkifItisWorkingDay(startDate.addDays(totalDays), holidayList)) {
            totalDays++;
        }
        return startDate.addDays(totalDays);
    }
    
    public static boolean checkifItisWorkingDay(Date currentDate, List<Holiday> holidays) {
        Date weekStart  = currentDate.toStartofWeek();
        for(Holiday hDay:holidays) {
            if(currentDate.daysBetween(hDay.ActivityDate) == 0) {
                return false;
            }
        }
        if(weekStart.daysBetween(currentDate) == 5 || weekStart.daysBetween(currentDate) == 6) {
            return false;
        } else {
            return true;    
        }
    }
    public static Integer calculateWorkingDays(Date startDate, Date endDate)
    { 
        
        //List<Holiday> holidays=[Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        List<Holiday> holidays = NHOS_CaseTriggerHandler.listOfHolidayCountryWise('Scotland');
        if(startDate != endDate)
        {
            Integer noOfDaysBetween = integer.valueOf(math.abs(startDate.daysBetween(endDate)));
            Integer allWorkingDays=0;
            
            for(Integer i=0;i<=noOfDaysBetween;i++) {
                if(checkifItisWorkingDay1(startDate.addDays(i),holidays)) {
                    allWorkingDays++;
                }
            }
            return allWorkingDays;
        }
        else{
            integer abc=1;
            return abc;
        }
        
    }
    
    public static boolean checkifItisWorkingDay1(Date currentDate, List<Holiday> holidays)
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