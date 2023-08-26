public without sharing class EI_EWI_AGLLEvidenceGathering {
    public EI_EWI_AGLLEvidenceGathering() {

    }
    public static List<Holiday> holidayList;
    
    public class wrapperEvidenceAttachment {
        @AuraEnabled public Case claim;
        @AuraEnabled public List<Evidence_Attachment__c> evidAttach;
        
        public wrapperEvidenceAttachment(Case claim, List<Evidence_Attachment__c> evidAttach) {
            this.claim = claim;
            this.evidAttach = evidAttach;
        }
    }

    public class DisputedAmountWrapper{
        @AuraEnabled public Double caseDisputedAmount;
        @AuraEnabled public String address;
        @AuraEnabled public String accountId;
    }

    @AuraEnabled(cacheable = true)
    public static List<DisputedAmountWrapper> setDisputedAmount(String accessCode){
        try {
            Case_Participant__c casePart = [select id,Case__r.Disputed_Amount__c,Case__r.Tenancy_Property_Address__c,Account__c from Case_Participant__c Where Access_Code__c = :accessCode];
            DisputedAmountWrapper da = new DisputedAmountWrapper();
            da.caseDisputedAmount = Double.valueOf(casePart.Case__r.Disputed_Amount__c);
            da.address = String.valueOf(casePart.Case__r.Tenancy_Property_Address__c);
            da.accountId = casePart.Account__c;
            List<DisputedAmountWrapper> daList = new List<DisputedAmountWrapper>();
            daList.add(da);
            return daList;
        } catch (Exception e) {
            System.debug('Exception in EI_EWI_AGLLShowDisputedAmount : '+e);
            return NULL;
        }
    }

    @AuraEnabled/*(cacheable = true)*/
    public static el_EWI_MyAccountClass.PersonDetailsWrapper getclaimdetailsforevidence (String accessCode){   
        
        /*Case_Participant__c cspar = [select Id,Case__c,Case__r.Total_Claim_Amount__c, Access_Code__c from Case_Participant__c 
                                     where Access_Code__c= :accessCode limit 1];
        
        /*Case casedata = [select Id,PreviousStatus__c from Case where Id =:cspar.Case__c limit 1 ];
        
        List<Case> caseparti = [select Id,caseNumber, Dispute_Reasons__c, Deposit_Account_Number__c,Total_Claim_Amount__c,Total_Claimed_by_Landlord__c,
                                Deposit_Account_Number__r.Name,Total_Agreed_by_Tenant__c,Respond_Date__c,TT_Made_offer__c,Deposit_Protected_Amount__c,
                                Deposit_Account_Number__r.Property_Address__c,Deposit_Account_Number__r.Status__c,Final_Amount_paid__c,
                                Deposit_Account_Number__r.Start_Date__c, Deposit_Account_Number__r.Deposit_Amount__c,External_ID__c,
                                Deposit_Account_Number__r.End_Date__c,Status,TT_Offer_Amount__c,Total_Deposit__c,Total_Agreed_by_AG_LL__c,
                                AGLL_made_Offer__c,AGLL_Offer_Amount__c,ZD_Reference_Number__c,Not_reach_an_agreement_Reason_AG_LL__c,
                                Claim_exceeds_the_total_level_of_cover__c,Claim_exceed__c,Claim_exceeds_comment_AGLL__c,Tenant_obligations__c,
                                inventorycheck_in_report_AGLL__c,check_out_report_AGLL__c,Rent_statement_AGLL__c,Consent_box_AGLL__c,
                                Additional_comments_AGLL__c,Additional_comments_TT__c,Dispute_Initiated_By__c,TT_respond_evidence_gathering__c,
                                Repayment_amount_to_AGLL__c,Repayment_amount_to_tenant__c,Agreed_amount_from_AGLL_to_TT__c, Total_Protected_Amount__c, 
                                (select Id,Name,Type__c,Contact_Email__c,Is_Lead__c,Contact__r.Name, Contact__r.Phone,Account__r.Tenant_External_ID__c
                                 from Case_Participants__r),
                                (select Id,Name,Adjustment_Percentage_by_AGLL__c,Adjustment_Percentage_by_TT__c,
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
                                //     Azure_File_Name__c,User_Type__c,File_Size__c, File_Description__c
                                //     from Evidence_Attachments__r)
                                
                                from case where id=:casedata.Id order by lastModifiedDate desc];*/
        // return caseparti;
        
        el_EWI_MyAccountClass.PersonDetailsWrapper detail = new el_EWI_MyAccountClass.PersonDetailsWrapper();
        List<Case_Participant__c> cpList = QuerySelectorHelper.getCaseParticipants(accessCode);
        if(cpList.isEmpty()){ return detail; }
        
        Case_Participant__c cspar = cpList[0];
        
        List<Case> caseparti = QuerySelectorHelper.getCase(new Set<Id>{cspar.Case__c});
        List<Dispute_Item__c> disputeItems = QuerySelectorHelper.getDisputeItem(cspar.Case__c);
        List<Evidence_Attachment__c> listOfEvidences = new List<Evidence_Attachment__c>();
        if(caseparti.size()>0) {
            listOfEvidences = [Select Id,Dispute_Item__c,Filename__c,Location__c,Evidence_Categories__c,File_Type__c,
                               Azure_File_Name__c,User_Type__c,File_Size__c,File_Description__c
                               from Evidence_Attachment__c where Dispute__c=:caseparti[0].Id];
        }
        
        detail.caseParticipants = cspar;
        detail = el_EWI_MyAccountClass.getAgentBank(caseparti[0], detail);
        detail.claim = caseparti[0];
        detail.disputeItems = disputeItems;
        detail.evidAttach = listOfEvidences;

        return detail;
    }

    // @AuraEnabled (cacheable=true)
    // public static list<case> getclaimdetailsforevidence(String accessCode)
    // { 
    //     system.debug('accessCode => ' + accessCode);
    //     String acCode = accessCode;
    //     system.debug('acCode => ' + acCode);
    //     Case_Participant__c cspar = [Select Id, Case__c, Access_Code__c from Case_Participant__c Where Access_Code__c =: accessCode];
    //     case casedata = [select id,PreviousStatus__c from case where Id =:cspar.Case__c   limit 1 ];
    //     // case casedata = [select id,PreviousStatus__c from case where Deposit_Account_Number__c=:depositid and (status=:'Evidence gathering AA/LL' OR (Status = 'On Hold'  AND  PreviousStatus__c ='Evidence gathering AA/LL')) limit 1 ];
    //     //string claimId = [select id,Case__c from Case_Participant__c where Access_Code__c=:AccessCode ]?.Case__c;
    //     list<case> caseparti = [select id,casenumber, Dispute_Reasons__c, Deposit_Account_Number__c,Total_Claim_Amount__c,Total_Claimed_by_Landlord__c,
    //                             Deposit_Account_Number__r.Name,Total_Agreed_by_Tenant__c,Respond_Date__c,TT_Made_offer__c,Deposit_Protected_Amount__c,
    //                             Deposit_Account_Number__r.Property_Address__c,Deposit_Account_Number__r.Status__c,Final_Amount_paid__c,
    //                             Deposit_Account_Number__r.Start_Date__c, Deposit_Account_Number__r.Deposit_Amount__c,External_ID__c,
    //                             Deposit_Account_Number__r.End_Date__c,Status,TT_Offer_Amount__c,Total_Deposit__c,Total_Agreed_by_AG_LL__c,
    //                             AGLL_made_Offer__c,AGLL_Offer_Amount__c,ZD_Reference_Number__c,Not_reach_an_agreement_Reason_AG_LL__c,
    //                             Claim_exceeds_the_total_level_of_cover__c,Claim_exceed__c,Claim_exceeds_comment_AGLL__c,Tenant_obligations__c,
    //                             inventorycheck_in_report_AGLL__c,check_out_report_AGLL__c,Rent_statement_AGLL__c,Consent_box_AGLL__c,
    //                             Additional_comments_AGLL__c,Additional_comments_TT__c,Dispute_Initiated_By__c,TT_respond_evidence_gathering__c,
    //                             Repayment_amount_to_AGLL__c,Repayment_amount_to_tenant__c,Agreed_amount_from_AGLL_to_TT__c,
    //                             (select id,Name,Type__c,Contact_Email__c,Is_Lead__c,Contact__r.Name, Contact__r.Phone,Account__r.Tenant_External_ID__c
    //                                 from Case_Participants__r),
    //                             (select id,Name,Adjustment_Percentage_by_AGLL__c,Adjustment_Percentage_by_TT__c,
    //                                 Agreed_by_AGLL__c,Agreed_by_Tenant__c,Claim_breakdown_other_AGLL__c,
    //                                 Claim_description_for_cleaning_agll__c,Claim_description_for_damage_agll__c,
    //                                 Claim_description_for_gardening_agll__c,Claim_description_for_redecoration_agll__c,
    //                                 Claimed_by_Landlord__c,Dispute__c,Evidence_at_tenancy_end_for_cleaning_agl__c,
    //                                 Evidence_at_tenancy_end_for_damage_agll__c,Evidence_at_tenancyend_gardening_agll__c,
    //                                 Evidence_at_tenancyend_redecoration_agll__c,Evidence_at_tenancystart_cleaning_agll__c,
    //                                 Evidence_at_tenancystart_damage_agll__c,Evidence_at_tenancystart_gardening_agll__c,
    //                                 Evidence_at_tenancystart_redecoration_ag__c,External_ID__c,Landlord_Statement__c,
    //                                 Other_Reason__c,Rent_arrears_description_agll__c,Supporting_clause_cleaning_agll__c,
    //                                 Supporting_clause_damage_agll__c,Supporting_clause_gardening_agll__c,Supporting_clause_other_agll__c,
    //                                 Supporting_clause_redecoration_agll__c,Supporting_clause_rent_agll__c,
    //                                 Supporting_evidence_for_cleaning_agll__c,Supporting_evidence_for_damage_agll__c,
    //                                 Supporting_evidence_for_gardening__c,Supporting_evidence_for_other_agll__c,
    //                                 Supporting_evidence_for_redecoration_agl__c,Supporting_evidence_for_rent_agll__c,
    //                                 Tenant_Response__c,Tenant_Statement__c,Type__c,Was_the_property_re_let_rent_agll__c,Is_Tenant_Agree__c,
    //                                 Is_Tenant_Upload_Evidence__c,Tenant_Disagree_comment__c, dispute_amount__c
    //                                 from Dispute_Items__r where dispute_amount__c >0),
    //                             (Select id,Dispute_Item__c,Filename__c,Location__c,Evidence_Categories__c,File_Type__c,
    //                                 Azure_File_Name__c,User_Type__c,File_Size__c
    //                                 from Evidence_Attachments__r)
                                
    //                             from case where id=:casedata.Id order by lastModifiedDate desc];
    //     return caseparti;
    // } 

    @AuraEnabled
    public static list<case> getclaimdetailsforevidenceForCancel(String depositid)
    { 
        return  [select id,casenumber, Dispute_Reasons__c, Deposit_Account_Number__c,Total_Claim_Amount__c,
                    Deposit_Account_Number__r.Name,Total_Agreed_by_Tenant__c,Respond_Date__c,TT_Made_offer__c,
                    Deposit_Account_Number__r.Property_Address__c,Deposit_Account_Number__r.Status__c,Final_Amount_paid__c,
                    Deposit_Account_Number__r.Start_Date__c, Deposit_Account_Number__r.Deposit_Amount__c,External_ID__c,
                    Deposit_Account_Number__r.End_Date__c,Status,TT_Offer_Amount__c,Total_Deposit__c,Total_Agreed_by_AG_LL__c,
                    AGLL_made_Offer__c,AGLL_Offer_Amount__c,ZD_Reference_Number__c,Not_reach_an_agreement_Reason_AG_LL__c,
                    Claim_exceeds_the_total_level_of_cover__c,Claim_exceeds_comment_AGLL__c,Tenant_obligations__c,
                    inventorycheck_in_report_AGLL__c,check_out_report_AGLL__c,Rent_statement_AGLL__c,Consent_box_AGLL__c,
                    Additional_comments_AGLL__c,Additional_comments_TT__c,Dispute_Initiated_By__c,TT_respond_evidence_gathering__c,
                    Repayment_amount_to_AGLL__c,Repayment_amount_to_tenant__c,Agreed_amount_from_AGLL_to_TT__c,
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
                    from Dispute_Items__r where dispute_amount__c >0),
                    (Select id,Dispute_Item__c,Filename__c,Location__c,Evidence_Categories__c,File_Type__c,
                    Azure_File_Name__c,User_Type__c,File_Size__c
                    from Evidence_Attachments__r)
                    
                    from case where Deposit_Account_Number__c=:depositid ANd status=:'Evidence gathering TT' limit 1 ];
    }  
    
    public static Boolean isSubmitEdiEvidenceAllowed(String caseId) {
        List<Case> caseList = [Select Id, Status from Case Where Id =:caseId];
        if(caseList.size() > 0 && caseList[0].Status == 'Evidence gathering agent/landlord'){
            return true;
        }else{
            return false;
        }
    }

    @AuraEnabled
    public static string updateClaimAGLL(string claimId,boolean consentBox)
    {
        if(isSubmitEdiEvidenceAllowed(claimId)){
            case caseToUpdate = new case(id=claimId,Consent_box_AGLL__c='Yes');
            update caseToUpdate;
            return 'Updated Successfully';
        }else{
            return 'Case Status Changed';
        }
    }
    
    @AuraEnabled
    public static string updatekeyDocuments(string caseRecID,string tenantObligation,string exceedclaim,string inventryChekReport,
                                            string checkOutReport,string rentStatement,string claimExceedsComment)
    {
        if(isSubmitEdiEvidenceAllowed(caseRecID)){
            case updatecaseList = new case(id=caseRecID,Tenant_obligations__c =tenantObligation,Claim_exceed__c=exceedclaim,inventorycheck_in_report_AGLL__c=inventryChekReport,
                                        check_out_report_AGLL__c=checkOutReport,Rent_statement_AGLL__c =rentStatement,
                                        Claim_exceeds_comment_AGLL__c=claimExceedsComment,AGLL_Respond_Evidance_Gathering__c=true);
            if(exceedclaim == 'Yes'){
                updatecaseList.Claim_exceeds_the_total_level_of_cover__c = true;
            }else{
                updatecaseList.Claim_exceeds_the_total_level_of_cover__c = false;
            }
            update updatecaseList;
            return 'Updated Successfully';
        }else{
            return 'Case Status Changed';
        }
    }
    
    @AuraEnabled
    public static string updateClaimBreakdown(string disputeItemRec, string caseId)
    {
        if(isSubmitEdiEvidenceAllowed(caseId)){
            List<Dispute_Item__c> updatedisputeList = (list<Dispute_Item__c>)System.JSON.deserialize(disputeItemRec, list<Dispute_Item__c>.class);
            update updatedisputeList;
            return 'Updated Successfully';
        }else{
            return 'Case Status Changed';
        }
    }
    
    @AuraEnabled
    public static string updateAdditionalComments(string caseId,string additionalComment)
    {
        if(isSubmitEdiEvidenceAllowed(caseId)){
            Id EWcaseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute EW Insured').getRecordTypeId();
            case caseToUpdate = new case(id=caseId,Additional_comments_AGLL__c=additionalComment, RecordTypeId=EWcaseRecordType);
            update caseToUpdate;
            return 'Updated Successfully';
        }else{
            return 'Case Status Changed';
        }
    }

    @AuraEnabled
    public static string UpdateClaimDetails(String claimId, String customerType,Decimal amount, String scheme, String claimExternalId )
    {
        
        string LeadTenantUrl; 
        if(customerType=='AGLL'){
            case  casetoUpdate=  new case(id=claimId,status='Case cancelled',Close_Reason__c='Case Closed',Claim_Agreed_By__c='Agent/Landlord');
            update casetoUpdate;
            LeadTenantUrl ='AGLL';
        }else if(customerType!='AGLL'){
            case  casetoUpdate=  new case(id=claimId,status='Case closed - agreement reached',Claim_Agreed_By__c='Tenant',Close_Reason__c='Agreement Reached',Make_Payment_By_Community__c = true);
            //   LeadTenantUrl= MakePayment(claimId,'Tenant',amount,scheme,claimExternalId);
            update casetoUpdate;
            
        }
        return LeadTenantUrl;
    }
    
    @AuraEnabled 
    public static string cancelclaimHoldingDisputedAmount(string caseid, Decimal disptAmount ) {
        if(isSubmitEdiEvidenceAllowed(caseid)){
            string successmessage = 'success';
            case querycase = [select Id,Total_amount_in_dispute__c From case where Id=: caseid limit 1];
            calculateWorkingDaysBetweenTwoDates(system.today(), 5);
            case  casetoUpdate=  new case(id=caseid, Amount_to_tenants__c = querycase.Total_amount_in_dispute__c, Dispute_resolution_status__c = 'Resolved without adjudication',status='Deposit to be repaid - resolved without adjudication',Bypass_validation__c=true,Respond_Date__c=calculateWorkingDaysBetweenTwoDates(system.today(), 5));
            paymentForCancelClaim(caseid, disptAmount);   
            update casetoUpdate;   
            EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
            EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper(casetoUpdate, 'cancelclaimHoldingDisputedAmount');
            helper.sendMailJetEmail(wrapper);
            
            return successmessage;
        }else{
            return 'Case Status Changed';
        }
    }

    @AuraEnabled 
    public static string cancelclaimNotHoldingDisputedAmount(string caseid, Decimal disptAmount ) {
        if(isSubmitEdiEvidenceAllowed(caseid)){
            string successmessage = 'success';
            case querycase = [select Id,Total_amount_in_dispute__c From case where Id=: caseid limit 1];
            calculateWorkingDaysBetweenTwoDates(system.today(), 5);
            case  casetoUpdate=  new case(id=caseid, Amount_to_tenants__c = querycase.Total_amount_in_dispute__c, Dispute_resolution_status__c = 'Resolved without adjudication',
            Resolved_Without_Adjudication_Reason__c = 'Agreed by AGLL in Evidence Gathering',
            status='Case closed – resolved without adjudication',Bypass_validation__c=true,Respond_Date__c=calculateWorkingDaysBetweenTwoDates(system.today(), 5));
            update casetoUpdate;   
            EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
            EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper(casetoUpdate, 'cancelclaimNotHoldingDisputedAmount');
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
        Map<Id,Installment__c> mapOfContactIdVsInst = new Map<Id,Installment__c>();

	    // get all case participants where type = 'Tenant'
	    case cs = [SELECT Id, Disputed_Amount__c, Status, Amount_to_tenants__c, Total_Deposit__c,Amount_to_agent_landlord__c, Deposit_Account_Number__r.Name, 
                  Tenancy_Property_Address__c, Deposit_Account_Number__c, Total_Agreed_by_AG_LL__c, Total_Agreed_by_Tenant__c, Agreed_amount__c, Total_amount_in_dispute__c,
                  Deposit_Protected_Amount__c, Remaining_protected_amount__c, Deposit_Account_Number__r.Agreed_amount__c,Respond_Date__c,FinalCaseBalance__c,
                  (SELECT Id, Account__c, Contact__c, Case__c, Contact__r.Name, Type__c, Contact__r.Email, Contact__r.FirstName, Contact__r.LastName, 
                   Payable_Amount__c, Split_percent__c, Case__r.Deposit_Account_Number__c, Case__r.Tenancy_Property_Address__c, 
                   Case__r.Deposit_Account_Number__r.Name, Case__r.Deposit_Account_Number__r.Payment_Received_By_Scheme__c ,Is_Lead__c,AGLL_Raised_Respond__c
                   FROM Case_Participants__r where Type__c = 'Tenant') FROM Case where Id =:caseId];
			   
        EI_InstallmentUtilityHelper installmentHelper = new EI_InstallmentUtilityHelper();
        Map<Id, EI_InstallmentUtilityHelper.InstallmentUtilityWrapper> installmentUtilityMap = new Map<Id, EI_InstallmentUtilityHelper.InstallmentUtilityWrapper>();
        
        EI_InstallmentUtilityHelper.InstallmentUtilityWrapper instWrap = new EI_InstallmentUtilityHelper.InstallmentUtilityWrapper();
        If(cs.FinalCaseBalance__c>0 && (cs.FinalCaseBalance__c > cs.Total_amount_in_dispute__c) ){
       	instWrap.AmountPaidTOTT = cs.Total_amount_in_dispute__c;
        }
        else if(cs.FinalCaseBalance__c>0 && (cs.FinalCaseBalance__c<=cs.Total_amount_in_dispute__c)){
         instWrap.AmountPaidTOTT = cs.FinalCaseBalance__c;
        }
        else{
         instWrap.AmountPaidTOTT = 0.00;    
        }
        instWrap.eachCase = cs;
        installmentUtilityMap.put(instWrap.eachCase.Id, instWrap);
        
        installmentHelper.createEWIInstallment(installmentUtilityMap);
        
        /*
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

  /*  @TestVisible
    private static void sendTenantCancelledClaimEmail(Case singCas, Decimal amountPerTenant){
        String SDSEmail = 'ADR@safedepositsscotland.com';
        
        String jsonBody;
        for(Case_Participant__c casPar : singCas.Case_Participants__r) {
            jsonBody = getJSONBODYforTT_SR(casPar,SDSEmail,amountPerTenant);
            
            if(String.isNotBlank(jsonBody)) {
                EI_EvidenceGatheringMails.evidenceGatheringSendEmailsTo1(jsonBody);
            }
        }
    }*/
    
  /*  private static String getJSONBODYforTT_SR(Case_Participant__c castInst,String SDSEmail, Decimal amountPerTenant){
        JSONGenerator gen = JSON.createGenerator(true);
        
        gen.writeStartObject();     
        gen.writeFieldName('Messages');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeFieldName('From');
        gen.writeStartObject();
        gen.writeStringField('Email', SDSEmail);
        gen.writeStringField('Name', 'SDS');
        gen.writeEndObject();
        
        gen.writeFieldName('To');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeStringField('Email', castInst.Contact__r.Email);
        gen.writeStringField('Name', castInst.Contact__r.FirstName + ' ' + castInst.Contact__r.LastName);
        gen.writeEndObject();      
        gen.writeEndArray();
        
        //String templateId = API_Service__mdt.getInstance('Resolve_without_consent').Template_Id__c; //@todo
        
        gen.writeNumberField('TemplateID', 3031154);
        gen.writeBooleanField('TemplateLanguage', true);
        
        String firstLine = castInst.Case__r.Tenancy_Property_Address__c;
        if(String.isNotBlank(firstLine)){
            firstLine = firstLine.split('\n')[0];
        }
        gen.writeStringField('Subject', 'Deposit repayment agreed - '+firstLine);
        
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  
        
        if(castInst.Is_Lead__c == false && castInst.Type__c == 'Tenant'){
            User userThatWithdrewConsent = [select contactid from user where id =: userInfo.getUserId()];
            contact userContact = [select Name from contact where id =: userThatWithdrewConsent.contactId];
            
            gen.writeStringField('tenantname', userContact.Name);
        }
        gen.writeNumberField('disputeamount', amountPerTenant);
        gen.writeEndObject(); 
        
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject(); 
        
        String jsonData = gen.getAsString(); 
        System.debug('jsonData- ' + jsonData);
        return jsonData;
        
    }*/
    
   /* public static void getInstallments(Case_Participant__c casePAr,Decimal AmountforInst,Boolean bol,MAp<String,Bank_Account__c> mapOFContactIdVsBankDet,Map<Id,cpm__Installment__c> mapOfContactIdVsInst){
        
        cpm__Installment__c Installmentrec = new cpm__Installment__c();
        Installmentrec.cpm__Contact__c = casePAr.Contact__c;
        Installmentrec.Created_at__c= date.today();
        Installmentrec.Credit_note_reference__c = null;
        Installmentrec.Payment_reference__c = null;//paymentReference
        Installmentrec.DAN__c = casePAr.Case__r.Deposit_Account_Number__c;                                                               
        Installmentrec.Case__c = casePAr.Case__c; 
        Installmentrec.cpm__Status__c = 'Pending processing';  
        //if(disuptedInst){
        //Installmentrec.cpm__Amount__c = AmountforInst;
        //mapOfContactIdVsInst.put(casePAr.Contact__c,Installmentrec);   
        //}
        Installmentrec.cpm__Amount__c = AmountforInst; 
        
        if(mapOFContactIdVsBankDet.containsKey(casePAr.Contact__c)){
            if(!mapOFContactIdVsBankDet.get(casePAr.Contact__c).ValidInternationBankDetails__c){
                Installmentrec.Payee_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Contact__r.name;
                Installmentrec.Bank_account_holder_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Bank_Account_Holder_Name__c;
                Installmentrec.Bank_account_number__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).International_Account_Number__c;
                Installmentrec.Bank_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).International_Bank_Name__c;
                Installmentrec.cpm__Custom_IBAN__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).IBAN__c;
            }else{
                Installmentrec.Payee_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Contact__r.name;
                Installmentrec.Bank_account_holder_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Bank_Account_Holder_Name__c;
                Installmentrec.Bank_account_number__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Account_Number__c;
                Installmentrec.Bank_sort_code__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Sort_Code__c;                                                                 
                Installmentrec.Bank_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Bank_Name__c;
            }
        }
        mapOfContactIdVsInst.put(casePAr.Contact__c,Installmentrec);   
    }*/
   
    @AuraEnabled(cacheable=true)
    public static List<Error_Message__mdt> fetchErrorLabel(){
        List<Error_Message__mdt> allError = [SELECT MasterLabel,Error_Message__c FROM Error_Message__mdt ];
        return allError;
    }
    
    @AuraEnabled
    public static Evidence_Attachment__c saveFile(Id parentId,string disputeId,string fileName,string azureLink,string userType,string fileType,
                                                  string fileSize, String fileLable,string evidenceCategories,
                                                  string fileNameInAzure,String source,String scheme)
    {
        if((userType == 'Tenant' && EI_EWI_TenantEvidenceGatheringClass.isSubmitEdiEvidenceAllowed(parentId)) || ((userType=='Agent' || userType=='Independent-Landlord' || userType=='Non-Member Landlord' || userType=='Landlord') && isSubmitEdiEvidenceAllowed(parentId))){
            Id EvidattachId = Schema.SObjectType.Evidence_Attachment__c.getRecordTypeInfosByName().get('EWI Evidence Attachment').getRecordTypeId();
            Evidence_Attachment__c recordToInsert = new Evidence_Attachment__c(Dispute__c =parentId,Recordtypeid =EvidattachId,Dispute_Item__c=(disputeId !='') ? disputeId :null,
                                                                            Filename__c =fileName,Thumbnail_Location__c='<a href="'+azureLink+'">'+azureLink+'</a>',
                                                                            User_Type__c=userType,Location__c=azureLink,
                                                                            File_Size__c=decimal.valueOf(fileSize),File_Type__c=fileType,
                                                                            Source__c=source,isUploaded__c=true,
                                                                            File_Description__c=fileLable,
                                                                            Evidence_Categories__c=evidenceCategories,
                                                                            Azure_File_Name__c =fileNameInAzure,
                                                                            created_date_external__c=System.now(),
                                                                            Scheme__c=scheme);
            insert recordToInsert;
            if(evidenceCategories =='Tenant obligations' || evidenceCategories =='Inventorycheck in report'||
            evidenceCategories =='Check out report'|| evidenceCategories =='Rent statement')
            {
                case caseToUpdate;
                if(evidenceCategories=='Tenant obligations')
                {
                    caseToUpdate  = new case(id =parentId,Tenant_obligations__c='Yes');
                }
                if(evidenceCategories=='Inventorycheck in report')
                {
                    caseToUpdate  = new case(id =parentId,inventorycheck_in_report_AGLL__c='Yes');
                }
                if(evidenceCategories=='Check out report')
                {
                    caseToUpdate  = new case(id =parentId,check_out_report_AGLL__c='Yes');
                }
                if(evidenceCategories=='Rent statement')
                {
                    caseToUpdate  = new case(id =parentId,Rent_statement_AGLL__c='Yes');
                }
                update caseToUpdate;
                
            }
            return recordToInsert;
        }else{
            return null;
        }
    }

    @AuraEnabled
    public static string deleteFileAzure(string fileNameInAzure,string RecordId,string evidenceCategories,string claimId,string scheme, string userType)
    {
        if((userType == 'Tenant' && EI_EWI_TenantEvidenceGatheringClass.isSubmitEdiEvidenceAllowed(claimId)) || ((userType=='Agent' || userType=='Independent-Landlord' || userType=='Non-Member Landlord' || userType=='Landlord') && isSubmitEdiEvidenceAllowed(claimId))){
            HttpRequest req = new HttpRequest();
            String baseUrl = getSecureURI(scheme);
            String endPoint = baseUrl.substringBefore('?')+'/'+fileNameInAzure+'?'+baseUrl.substringAfter('?');
            
            System.debug('endPoint => ' + endPoint);
            // String endpoint = EI_SDS_EvidenceUploadToAzure.generateSASToken(fileNameInAzure,'d',scheme);
            // system.debug('endpoint--->>'+endpoint);
            req.setEndpoint(endPoint);
            req.setMethod('DELETE');
            Http http = new Http();
            if(!test.isRunningTest())
                HTTPResponse res = http.send(req);
            
            // Evidence_Attachment__c EA = [select id, Evidence_Categories__c,Dispute__c from Evidence_Attachment__c where id=:RecordId limit 1];
            if(evidenceCategories =='Tenant obligations' || evidenceCategories =='Inventorycheck in report'||
                evidenceCategories =='Check out report'|| evidenceCategories =='Rent statement')
            {
                case caseToUpdate;
                
                if(evidenceCategories=='Tenant obligations')
                {
                    caseToUpdate  = new case(id =claimId,Tenant_obligations__c='');
                }
                if(evidenceCategories=='Inventorycheck in report')
                {
                    caseToUpdate  = new case(id =claimId,inventorycheck_in_report_AGLL__c='');
                }
                if(evidenceCategories=='Check out report')
                {
                    caseToUpdate  = new case(id =claimId,check_out_report_AGLL__c='');
                }
                if(evidenceCategories=='Rent statement')
                {
                    caseToUpdate  = new case(id =claimId,Rent_statement_AGLL__c='');
                }
                update caseToUpdate;
            }
            Database.delete(RecordId); 
            return 'deleted';
        }else{
            return 'null';
        }
    }

    @AuraEnabled (cacheable=true)
    public static List<Evidence_Attachment__c> getEvidanceAttachments(String claimId){
        try {
            List<Evidence_Attachment__c> eviAttachments = [Select id,Dispute_Item__c,Filename__c,Location__c,Evidence_Categories__c,File_Type__c,
            Azure_File_Name__c,User_Type__c,File_Size__c from Evidence_Attachment__c Where Dispute_Item__c=:claimId];
            return eviAttachments;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled (cacheable=true)
    public static String getHelpArticleDocument(){
        //Document doc = [Select Id from Document where Name = 'TDSHelpArticle' limit 1];
        //return String.valueOf(doc.Id);
        return '';
    }

    private static Azure_Storage_Credentials_per_Scheme__mdt getAzureMetadata(String scheme) {
        Azure_Storage_Credentials_per_Scheme__mdt settings;
        try {
            settings = [
                SELECT Account_Name_Production__c,
                Account_Name_Sandbox__c,
                Container_Name_Production__c,
                Container_Name_Sandbox__c,
                Endpoint_Production__c,
                Endpoint_Sandbox__c,
                Secure_URI_Production__c,
                Secure_URI_Sandbox__c,
                Storage_Key_Production__c,
                Storage_Key_Sandbox__c
                FROM Azure_Storage_Credentials_per_Scheme__mdt
                WHERE Label = :scheme
            ];
        }
        catch(QueryException exc) {
            //throw new AzureFunctionFileUploadServiceException('No Azure Upload Function Credentials found for scheme: ');
        }
        return settings;
    }

    private static Boolean isRunningOnSandbox;
    
    public static Boolean isRunningOnSandbox() {
        if(isRunningOnSandbox == null) {
            isRunningOnSandbox = [SELECT IsSandbox FROM Organization].IsSandbox;
        }
        return isRunningOnSandbox;
    }

    @AuraEnabled(cacheable=true)
    public static String getSecureURI(String scheme){
        System.debug('Line 296 -> '+scheme);
        Azure_Storage_Credentials_per_Scheme__mdt settings = getAzureMetadata(scheme);
        System.debug('Line 297 -> '+(isRunningOnSandbox() ? settings.Secure_URI_Sandbox__c : settings.Secure_URI_Production__c));
        return isRunningOnSandbox() ? settings.Secure_URI_Sandbox__c : settings.Secure_URI_Production__c;
    }
}