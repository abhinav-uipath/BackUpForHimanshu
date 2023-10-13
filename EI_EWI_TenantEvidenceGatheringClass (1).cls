public without sharing class EI_EWI_TenantEvidenceGatheringClass {

    public static List<Holiday> holidayList;

    public class wrapperEvidenceAttachment {
        @AuraEnabled public Case claim;
        @AuraEnabled public List<Evidence_Attachment__c> evidAttach;
        
        public wrapperEvidenceAttachment(Case claim, List<Evidence_Attachment__c> evidAttach) {
            this.claim = claim;
            this.evidAttach = evidAttach;
        }
    }

    @AuraEnabled(cacheable = true)
    public static Boolean isSubmitEdiEvidenceAllowed(String caseId) {
        List<Case> caseList = [Select Id, Status from Case Where Id =:caseId];
        if(caseList.size() > 0 && caseList[0].Status == 'Evidence gathering tenant'){
            return true;
        }else{
            return false;
        }
    }

    @AuraEnabled/*(cacheable = true)*/
    public static el_EWI_MyAccountClass.PersonDetailsWrapper getclaimdetailsInTenantEvidence(String accessCode){   
        
        /*Case_Participant__c cspar = [select id,Case__c,Case__r.Total_Claim_Amount__c, Access_Code__c from Case_Participant__c 
                                     where Access_Code__c= :accessCode limit 1];
        case casedata = [select id,PreviousStatus__c from case where Id =:cspar.Case__c   limit 1 ];
        list<case> caseparti = [select id,casenumber, Dispute_Reasons__c, Deposit_Account_Number__c,Total_Claim_Amount__c,Total_Claimed_by_Landlord__c,
                                Deposit_Account_Number__r.Name,Total_Agreed_by_Tenant__c,Respond_Date__c,TT_Made_offer__c,Deposit_Protected_Amount__c,
                                Deposit_Account_Number__r.Property_Address__c,Deposit_Account_Number__r.Status__c,Final_Amount_paid__c,Consent_box_TT__c,
                                Deposit_Account_Number__r.Start_Date__c, Deposit_Account_Number__r.Deposit_Amount__c,External_ID__c,
                                Deposit_Account_Number__r.End_Date__c,Status,TT_Offer_Amount__c,Total_Deposit__c,Total_Agreed_by_AG_LL__c,
                                AGLL_made_Offer__c,AGLL_Offer_Amount__c,ZD_Reference_Number__c,Not_reach_an_agreement_Reason_AG_LL__c,
                                Claim_exceeds_the_total_level_of_cover__c,Claim_exceed__c,Claim_exceeds_comment_AGLL__c,Tenant_obligations__c,
                                inventorycheck_in_report_AGLL__c,check_out_report_AGLL__c,Rent_statement_AGLL__c,Consent_box_AGLL__c,
                                Additional_comments_AGLL__c,Additional_comments_TT__c,Dispute_Initiated_By__c,TT_respond_evidence_gathering__c,
                                Repayment_amount_to_AGLL__c,Repayment_amount_to_tenant__c,Agreed_amount_from_AGLL_to_TT__c, Total_Protected_Amount__c,
                                (select id,Name,Type__c,Contact_Email__c,Is_Lead__c,Contact__r.Name, Contact__r.Phone,Account__r.Tenant_External_ID__c
                                 from Case_Participants__r),
                                (select id,Name,Adjustment_Percentage_by_AGLL__c,Adjustment_Percentage_by_TT__c,
                                 Agreed_by_AGLL__c,Agreed_by_Tenant__c,Claim_breakdown_other_AGLL__c,
                                 Claim_description_for_cleaning_agll__c,Claim_description_for_damage_agll__c,
                                 Claim_description_for_gardening_agll__c,Claim_description_for_redecoration_agll__c,
                                 Claimed_by_Landlord__c,Dispute__c,Evidence_at_tenancy_end_for_cleaning_agl__c,
                                 Evidence_at_tenancy_end_for_damage_agll__c,Evidence_at_tenancyend_gardening_agll__c,
                                 Evidence_at_tenancyend_redecoration_agll__c,Evidence_at_tenancystart_cleaning_agll__c,
                                 Evidence_at_tenancystart_damage_agll__c,Evidence_at_tenancystart_gardening_agll__c,
                                 Evidence_at_tenancystart_redecoration_ag__c,External_ID__c,Landlord_Statement__c,
                                 Other_Reason__c,Rent_arrears_description_agll__c,Supporting_clause_cleaning_agll__c,
                                 Supporting_clause_damage_agll__c,Supporting_clause_gardening_agll__c,Supporting_clause_other_agll__c,
                                 Supporting_clause_redecoration_agll__c,Supporting_clause_rent_agll__c,
                                 Supporting_evidence_for_cleaning_agll__c,Supporting_evidence_for_damage_agll__c,
                                 Supporting_evidence_for_gardening__c,Supporting_evidence_for_other_agll__c,
                                 Supporting_evidence_for_redecoration_agl__c,Supporting_evidence_for_rent_agll__c,
                                 Tenant_Response__c,Tenant_Statement__c,Type__c,Was_the_property_re_let_rent_agll__c,Is_Tenant_Agree__c,
                                 Is_Tenant_Upload_Evidence__c,Tenant_Disagree_comment__c, dispute_amount__c
                                 from Dispute_Items__r where dispute_amount__c >0)
                                //     ,
                                // (Select id,Dispute_Item__c,Filename__c,Location__c,Evidence_Categories__c,File_Type__c,
                                //     Azure_File_Name__c,User_Type__c,File_Size__c,File_Description__c
                                //     from Evidence_Attachments__r)
                                
                                from case where id=:casedata.Id order by lastModifiedDate desc];
        
        system.debug('line-->46' + caseparti);
        // return caseparti;*/
        
        List<Case_Participant__c> cpList = QuerySelectorHelper.getCaseParticipants(accessCode);
        if(cpList.isEmpty()){ return null; }
        
        Case_Participant__c cspar = cpList[0];
        
        List<Case> caseparti = QuerySelectorHelper.getCase(new Set<Id>{cspar.Case__c});
        List<Dispute_Item__c> disputeItems = QuerySelectorHelper.getDisputeItem(cspar.Case__c);
        List<Evidence_Attachment__c> listOfEvidences = new List<Evidence_Attachment__c>();
        
        if(caseparti.size()>0) {
            listOfEvidences = [Select Id,Dispute_Item__c,Filename__c,Location__c,Evidence_Categories__c,File_Type__c,
                               Azure_File_Name__c,User_Type__c,File_Size__c,File_Description__c
                               from Evidence_Attachment__c where Dispute__c=:caseparti[0].Id];
        }
        
        el_EWI_MyAccountClass.PersonDetailsWrapper detail = new el_EWI_MyAccountClass.PersonDetailsWrapper();
        detail.caseParticipants = cspar;
        detail.claim = caseparti[0];
        detail.disputeItems = disputeItems;
        detail.evidAttach = listOfEvidences;
        detail.isBankDetailsEmpty = false;
        
        if((String.isBlank(cspar.Bank_Name__c) || String.isBlank(cspar.Bank_Sort_Code__c)) //UK
           && (String.isBlank(cspar.International_Account_Number__c) || String.isBlank(cspar.International_Bank_Account_Holder_Name__c))){
               detail.isBankDetailsEmpty = true;
           }
        
        return detail;
    }
    
    // @AuraEnabled
    // public static void updateClaimItemTT(string disputeItemRec,string claimId,boolean isTenantRespond)
    // {
    //     List<Dispute_Item__c> updatedisputeList = (list<Dispute_Item__c>)System.JSON.deserialize(disputeItemRec, list<Dispute_Item__c>.class);
    //     update updatedisputeList;
    //     if(!isTenantRespond)
    //     {
    //         case claimToUpdate = new case(Id=claimId,TT_respond_evidence_gathering__c = true);
    //         // update claimToUpdate;
    //     }
    // }

    @AuraEnabled
    public static String updateClaimItemTT(string disputeItemRec, string claimId, boolean isTenantRespond)
    {
        if(isSubmitEdiEvidenceAllowed(claimId)){
            List<Dispute_Item__c> updatedisputeList = (list<Dispute_Item__c>)System.JSON.deserialize(disputeItemRec, list<Dispute_Item__c>.class);
            update updatedisputeList;
            if(!isTenantRespond)
            {
                case claimToUpdate = new case(Id=claimId,TT_respond_evidence_gathering__c = true);
                update claimToUpdate;
            }
            return 'Updated Successfully';
        }else{
            return 'Case Status Changed';
        }
    }

    @AuraEnabled
    public static String updateClaimTT(string claimId,boolean consentBox)
    {
        if(isSubmitEdiEvidenceAllowed(claimId)){
            case caseToUpdate = new case(id=claimId,Consent_box_TT__c='Yes');
            update caseToUpdate;
            return 'Updated Successfully';
        }else{
            return 'Case Status Changed';
        }
    }

    @AuraEnabled
    public static String updateAdditionalCommentsTT(string caseId,string additionalComment)
    {
        if(isSubmitEdiEvidenceAllowed(caseId)){
            Id EWcaseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute EW Insured').getRecordTypeId();
            case caseToUpdate = new case(id=caseId, Additional_comments_TT__c=additionalComment, RecordTypeId=EWcaseRecordType);
            update caseToUpdate;
            return 'Updated Successfully';
        }else{
            return 'Case Status Changed';
        }
    }

    @AuraEnabled 
    public static string cancelclaimHoldingDisputedAmount(string caseid, Decimal disptAmount ) {
        if(isSubmitEdiEvidenceAllowed(caseid)){
            system.debug('line-->132 ++' + disptAmount);
            string successmessage = 'success';
            case querycase = [select Id,Total_amount_in_dispute__c From case where Id=: caseid limit 1];
            calculateWorkingDaysBetweenTwoDates(system.today(), 5);
            case  casetoUpdate=  new case(id=caseid, Amount_to_agent_landlord__c = querycase.Total_amount_in_dispute__c, Dispute_resolution_status__c = 'Resolved without adjudication',status='Deposit to be repaid - resolved without adjudication',Bypass_validation__c=true,Respond_Date__c=calculateWorkingDaysBetweenTwoDates(system.today(), 5));
            system.debug('line-->137 ++' + casetoUpdate);
            paymentForCancelClaim(caseid, disptAmount);   
            update casetoUpdate;   
            
            return successmessage;
        }else{
            return 'Case Status Changed';
        }
    }

    @AuraEnabled 
    public static string cancelclaimNotHoldingDisputedAmount(string caseid, Decimal disptAmount ) {
        if(isSubmitEdiEvidenceAllowed(caseid)){    
            system.debug('line-->144 ++' + disptAmount);
            string successmessage = 'success';
            case querycase = [select Id,Total_amount_in_dispute__c From case where Id=: caseid limit 1];
            calculateWorkingDaysBetweenTwoDates(system.today(), 5);
            case  casetoUpdate=  new case(id=caseid, Amount_to_agent_landlord__c = querycase.Total_amount_in_dispute__c, Dispute_resolution_status__c = 'Resolved without adjudication',status='Case closed – resolved without adjudication',Bypass_validation__c=true,Respond_Date__c=calculateWorkingDaysBetweenTwoDates(system.today(), 5));
            system.debug('line-->149 ++' + disptAmount);
            update casetoUpdate;  
            
            EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
            EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper(casetoUpdate, 'EID26AC137MailToAllParty');
            if(!test.isRunningTest())
                helper.sendMailJetEmail(wrapper);
            
            return successmessage;
        }else{
            return 'Case Status Changed';
        }
            
    }
    
    public static Date calculateWorkingDaysBetweenTwoDates(Date startDate, Integer noOfDays)
    {
        if(startDate == null){
            return null;
        }
        if(holidayList == null || holidayList.isEmpty()){
            holidayList = [Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        }
        Integer allWorkingDays=0;
        Integer totalDays = 1;
        while(allWorkingDays<=noOfDays)
        {
            if(checkifItisWorkingDay(startDate.addDays(totalDays),holidayList)){
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
    
    public static boolean checkifItisWorkingDay(Date currentDate, List<Holiday> holidays)
    {
        Date weekStart  = currentDate.toStartofWeek();
        for(Holiday hDay:holidays) {
            if(currentDate.daysBetween(hDay.ActivityDate) == 0) {
                return false;
            }
        }
        if(weekStart.daysBetween(currentDate) ==5 || weekStart.daysBetween(currentDate) == 6){
            return false;
        } 
        else
        {
            return true;    
        }
    }
    
    public static void paymentForCancelClaim(Id caseId, Decimal disptAmount) {
        
        // get all case participants where type != 'Tenant'
	    Case cs = [SELECT Id, Disputed_Amount__c, Status, Amount_to_tenants__c, Total_Deposit__c,Amount_to_agent_landlord__c, Deposit_Account_Number__r.Name, 
                  Tenancy_Property_Address__c, Deposit_Account_Number__c, Total_Agreed_by_AG_LL__c, Total_Agreed_by_Tenant__c, Agreed_amount__c, FinalCaseBalance__c,
                  Deposit_Protected_Amount__c, Remaining_protected_amount__c, Deposit_Account_Number__r.Agreed_amount__c,Respond_Date__c,Final_case_balance__c,
                  Total_amount_in_dispute__c,
                  (SELECT Id, Account__c, Contact__c, Case__c, Contact__r.Name, Type__c, Contact__r.Email, Contact__r.FirstName, Contact__r.LastName, 
                   Payable_Amount__c, Split_percent__c, Case__r.Deposit_Account_Number__c, Case__r.Tenancy_Property_Address__c,
                   Case__r.Deposit_Account_Number__r.Name, Case__r.Deposit_Account_Number__r.Payment_Received_By_Scheme__c ,Is_Lead__c,AGLL_Raised_Respond__c
                   FROM Case_Participants__r where Type__c != 'Tenant') FROM Case where Id =:caseId];
        
        EI_InstallmentUtilityHelper installmentHelper = new EI_InstallmentUtilityHelper();
        Map<Id, EI_InstallmentUtilityHelper.InstallmentUtilityWrapper> installmentUtilityMap = new Map<Id, EI_InstallmentUtilityHelper.InstallmentUtilityWrapper>();
        
        EI_InstallmentUtilityHelper.InstallmentUtilityWrapper instWrap = new EI_InstallmentUtilityHelper.InstallmentUtilityWrapper();
        If(cs.FinalCaseBalance__c>0 && (cs.FinalCaseBalance__c > cs.Total_amount_in_dispute__c) ){
       	instWrap.AmountPaidTOLL = cs.Total_amount_in_dispute__c;
        }
        else if(cs.FinalCaseBalance__c>0 && (cs.FinalCaseBalance__c<=cs.Total_amount_in_dispute__c)){
         instWrap.AmountPaidTOLL = cs.FinalCaseBalance__c;
        }
        else{
         instWrap.AmountPaidTOLL = 0.00;    
        }
        instWrap.eachCase = cs;
      // 	instWrap.AmountPaidTOLL = disptAmount;
        installmentUtilityMap.put(instWrap.eachCase.Id, instWrap);
        
        installmentHelper.createEWIInstallment(installmentUtilityMap);
        
        
        /*Map<Id,Installment__c> mapOfContactIdVsInst = new Map<Id,Installment__c>();
        integer countTT = cs.Case_Participants__r.size();
        Set<String> ContactIds = new Set<String>();
        for(Case_Participant__c casPar : cs.Case_Participants__r){
            ContactIds.add(casPar.Contact__c);
        }
        
        Map<String,Bank_Account__c> mapOFContactIdVsBankDet = getBanKDetails(ContactIds); //EI_TenantRespondToRepayment refered

        for(Case_Participant__c casPar : cs.Case_Participants__r) {
        
            Decimal amtToTen = (disptAmount/ countTT); 
            getNewInstallments(casPar, amtToTen, false, null, mapOFContactIdVsBankDet, mapOfContactIdVsInst, null, null); // EI_EWI_Paymentutilityclass refered
        }
        
        if(!mapOfContactIdVsInst.isEmpty()){
            insert mapOfContactIdVsInst.values();
        }*/
    }

    /*public static Map<String, Bank_Account__c> getBanKDetails(Set<String> userContactId) {
        System.debug('userContactId -> '+userContactId);
        Map<String, Bank_Account__c> bankDetail = new Map<String, Bank_Account__c>(); 
        List<Bank_Account__c> baList = 
            [SELECT Account__c, Is_Active__c, BIC__c, Bank_Name__c, IBAN__c, Sort_Code__c, Contact__c, Bank_Account_Holder_Name__c, 
             Account_Number__c, Bank_Address__c, International_Account_Number__c, International_Bank_Account_Holder_Name__c, 
             International_Bank_Name__c, Swift_Code__c, Contact__r.name,ValidInternationBankDetails__c
             FROM Bank_Account__c WHERE Contact__c IN :userContactId AND Contact__c != NULL
             ORDER BY createddate desc //LIMIT 1
            ];
        if(baList.size()>0){
            for(Bank_Account__c ba : baList){
                bankDetail.put(ba.Contact__c,ba);
            }
        }
        System.debug('329bankDetail -> '+bankDetail);
        return bankDetail;
    }
    public static void getNewInstallments(Case_Participant__c casePAr, Decimal AmountforInst, Boolean bol, String category, 
        Map<String,Bank_Account__c> mapOFContactIdVsBankDet, Map<Id,Installment__c> mapOfContactIdVsInst, 
        String paymentType, String paymentTypeStatus)
    {
            Id installmentRecordType;    installmentRecordType = Schema.SObjectType.Installment__c.getRecordTypeInfosByName().get('EWI Installment').getRecordTypeId();

        Installment__c Installmentrec = new Installment__c();
        Installmentrec.RecordTypeId = installmentRecordType;
        Installmentrec.Contact__c = casePAr.Contact__c;
        Installmentrec.Created_at__c= date.today();
        Installmentrec.Credit_note_reference__c = null;
        Installmentrec.Payment_reference__c = null;//paymentReference
        Installmentrec.Deposit__c = casePAr.Case__r.Deposit_Account_Number__c;                                                               
        Installmentrec.Case__c = casePAr.Case__c; 
        Installmentrec.Status__c =null;
        Installmentrec.Category__c=category;
        Date daysCompletionDate = calculateWorkingDaysBetweenTwoDates(casePAr.Case__r.Deposit_Account_Number__r.Payment_Received_By_Scheme__c,30);
        if(daysCompletionDate != null){
            Installmentrec.X30_Days_Completion_Date__c = daysCompletionDate;
        }

        Installmentrec.Payment_type__c = paymentType;
        Installmentrec.Payment_type_status__c = paymentTypeStatus;
        Installmentrec.Due_Date__c = calculateWorkingDaysBetweenTwoDates(date.today(), 5);
        Installmentrec.Installment_Type__c = null;
        //X30_Days_Completion_Date__c??


        Installmentrec.Amount__c = AmountforInst; 

        if(mapOFContactIdVsBankDet.containsKey(casePAr.Contact__c)){
            if(!mapOFContactIdVsBankDet.get(casePAr.Contact__c).ValidInternationBankDetails__c){
        //Installmentrec.Payee_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Contact__r.name;
        Installmentrec.Bank_account_holder_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).International_Bank_Account_Holder_Name__c;
        Installmentrec.Bank_account_number__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).International_Account_Number__c;
        Installmentrec.Bank_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).International_Bank_Name__c;
        Installmentrec.Custom_Account_Number__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).IBAN__c; //International bank details (IBAN)
        Installmentrec.Swift_Code__c = 	mapOFContactIdVsBankDet.get(casePAr.Contact__c).Swift_Code__c; //International bank details (Swift Code)
        Installmentrec.BIC__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).BIC__c; //International bank details (BIC)
        Installmentrec.International_Payment__c = true;
        // Installmentrec.cpm__Custom_IBAN__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).IBAN__c;
        }
        else{
        //Installmentrec.Payee_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Contact__r.name;
        Installmentrec.Bank_account_holder_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Bank_Account_Holder_Name__c;
        Installmentrec.Bank_account_number__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Account_Number__c;
        Installmentrec.Bank_sort_code__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Sort_Code__c;                                                                 
        Installmentrec.Bank_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Bank_Name__c;
        Installmentrec.International_Payment__c = false;
        }
    }
        mapOfContactIdVsInst.put(casePAr.Contact__c,Installmentrec);   
    }*/

    @AuraEnabled (cacheable=true)
    public static String getHelpArticleDocument(){
        //Document doc = [Select Id from Document where Name = 'TDSHelpArticle' limit 1];
       // return String.valueOf(doc.Id);
       return '';
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Error_Message__mdt> fetchErrorLabel(){
        List<Error_Message__mdt> allError = [SELECT MasterLabel,Error_Message__c FROM Error_Message__mdt ];
        return allError;
    }
}