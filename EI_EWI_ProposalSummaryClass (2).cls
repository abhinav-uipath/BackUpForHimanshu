public without sharing class EI_EWI_ProposalSummaryClass {
    public EI_EWI_ProposalSummaryClass() {}
    
    @AuraEnabled
    public static Case_Participant__c getCaseCurrentDetails(String accessCode){
        try {
            List<Case_Participant__c> currentCaseDetails = [Select Id, Type__c, AGLL_Raised_Respond__c, Is_Lead__c,
            Case__c, Case__r.Status, Case__r.AGLL_Respond_Evidance_Gathering__c From Case_Participant__c Where Access_Code__c =: accessCode];
            return currentCaseDetails[0];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static el_EWI_MyAccountClass.PersonDetailsWrapper getHeaderDetails (String accessCode){   
        try {
            el_EWI_MyAccountClass.PersonDetailsWrapper detail = new el_EWI_MyAccountClass.PersonDetailsWrapper();
            
            List<Case_Participant__c> cp = [select Id,Case__c,Case__r.Total_Claim_Amount__c,Account__r.RecordType.Name, Case__r.Deposit_Account_Number__r.Property__r.Name,
            Case__r.Deposit_Account_Number__r.End_Date__c,Case__r.Status,Case__r.Deposit_Account_Number__r.Property_Address__c,Case__r.Deposit_Account_Number__r.Deposit_Amount__c,
          Case__r.Deposit_funds_not_received__c, Case__r.Tenant_not_received_funds__c, Case__r.Hide_Grey_Side_Bar__c, Case__r.Amount_to_tenants__c, Case__r.Resolved_Without_Adjudication_Reason__c,AGLL_Raised_Respond__c,
            Case__r.Total_Deposit__c,Account__r.Name,Contact__r.Name, Case__r.Deposit_Account_Number__r.Lead_Tenant_Name__c,
            Case__r.Amount_Returned_to_Landlord__c, Case__r.V_External_Id__c,Access_Code__c,Is_Lead__c,Case__r.Respond_Date__c ,Type__c, Case__r.Lead_Tenant_Name__c, Case__r.Nr_Of_Lead_Tenants__c,Case__r.Dispute_Initiated_By__c,
            Case__r.Dispute_resolution_status__c, Case__r.AGLL_Respond_Evidance_Gathering__c, Case__r.TT_respond_evidence_gathering__c,
            Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,Case__r.Deposit_Account_Number__r.Property__r.House_No__c,Case__r.Claim_exceed_amount__c,
            Case__r.Deposit_Account_Number__r.Property__r.Street__c,Case__r.Deposit_Account_Number__r.Property__r.City__c,Case__r.Deposit_Account_Number__r.Property__r.County__c,
            Case__r.Deposit_Account_Number__r.Property__r.Postal_Code__c,Case__r.Deposit_Account_Number__r.Property__r.Country__c
            from Case_Participant__c where Access_Code__c= :accessCode limit 1]; 
            
            if(cp.isEmpty()){ return detail; }
            
            detail.caseParticipants = cp[0];
            List<Case_Participant__c> leadTenantList = QuerySelectorHelper.getLeadTenant(new Set<Id>{cp[0].Case__c});
            
            if(!leadTenantList.isEmpty()){
                detail.leadTenant = leadTenantList[0];
            }
            return detail;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled 
    public static void nullifyAccessCode (String cp_accessCode){
        List<Case_Participant__c> cp = [select Id from Case_Participant__c where Access_Code__c =: cp_accessCode];
        if(cp.isEmpty()){return; }
        cp[0].Access_Code__c = null;
        update cp;
    }
    
    @AuraEnabled(cacheable = true)
    public static el_EWI_MyAccountClass.PersonDetailsWrapper getCaseParticipantDetails (String accessCode)
    {   
        try {
            el_EWI_MyAccountClass.PersonDetailsWrapper detail = new el_EWI_MyAccountClass.PersonDetailsWrapper();
            
            List<Case_Participant__c> casedetails = [select Id,Case__c,Case__r.Total_Claim_Amount__c,Account__r.RecordType.Name, Case__r.Deposit_Account_Number__r.Property__r.Name,
            Case__r.Deposit_Account_Number__r.End_Date__c,Case__r.Status,Case__r.Deposit_Account_Number__r.Property_Address__c,Case__r.Deposit_Account_Number__r.Deposit_Amount__c,
            Case__r.Deposit_funds_not_received__c, Case__r.Tenant_not_received_funds__c, Case__r.Hide_Grey_Side_Bar__c, Case__r.Amount_to_tenants__c, Case__r.Resolved_Without_Adjudication_Reason__c,AGLL_Raised_Respond__c,
            Case__r.Total_Deposit__c,Account__r.Name,Contact__r.Name, Case__r.Deposit_Account_Number__r.Lead_Tenant_Name__c, Case__r.No_of_AGLL_evidences__c, Case__r.No_of_tenant_evidence__c,
            Case__r.Amount_Returned_to_Landlord__c, Case__r.V_External_Id__c,Access_Code__c,Is_Lead__c,Case__r.Respond_Date__c ,Type__c, Case__r.Lead_Tenant_Name__c, Case__r.Nr_Of_Lead_Tenants__c,Case__r.Dispute_Initiated_By__c,
            Case__r.Dispute_resolution_status__c, Case__r.AGLL_Respond_Evidance_Gathering__c, Case__r.TT_respond_evidence_gathering__c,
            Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,Case__r.Deposit_Account_Number__r.Property__r.House_No__c,Case__r.Claim_exceed_amount__c,
            Case__r.Deposit_Account_Number__r.Property__r.Street__c,Case__r.Deposit_Account_Number__r.Property__r.City__c,Case__r.Deposit_Account_Number__r.Property__r.County__c,
            Case__r.Deposit_Account_Number__r.Property__r.Postal_Code__c,Case__r.Deposit_Account_Number__r.Property__r.Country__c,Case__r.Deposit_Account_Number__r.Property__r.Saon__c
            from Case_Participant__c where Access_Code__c= :accessCode limit 1]; 
            
            if( casedetails.isEmpty()){ return detail; }
            
            detail.caseParticipants = casedetails[0];
            List<Case_Participant__c> leadTenantList = QuerySelectorHelper.getLeadTenant(new Set<Id>{casedetails[0].Case__c});
            
            if(!leadTenantList.isEmpty()){
                detail.leadTenant = leadTenantList[0];
                detail.containsleadtenant = true;
            }
            else{
                detail.containsleadtenant = false;   
            }
            
            return detail;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable = true)
    public static Case getCaseandDispiteItemsDetails (Id caseId)
    {
        try {
            Case cs = [select id, Deposit_Account_Number__c,V_External_Id__c, Deposit_Account_Number__r.Property_Address__c, Deposit_Account_Number__r.End_Date__c, Deposit_Account_Number__r.Deposit_Amount__c,
            Status, Deposit_Account_Number__r.Lead_Tenant_Name__c, Amount_Returned_to_Landlord__c,
            (Select Id, Dispute__c, Type__c, Claimed_by_Landlord__c, Other_Reason__c FROM Dispute_Items__r where Dispute__c =:caseId),
            (Select Id, AGLL_Raised_Respond__c, Account__r.Name FROM Case_Participants__r Where AGLL_Raised_Respond__c = true and type__c !='Tenant')
            FROM Case where Id= :caseId limit 1]; 
            return cs;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Case getCaserecord(Id caseId)
    {
        try {
            Case cs = [select id, Deposit_Account_Number__c, Status,Tenant_not_received_funds__c,LL_Evidence_Extension_Granted__c,Evidence_Extension_Target_Date__c,TT_Evidence_Extension_Granted__c
            FROM Case where Id= :caseId limit 1]; 
            return cs;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Case updatefundstatus(Id caseId,string operation)
    {
        case caseobj = new case ();
        
        try {
            caseobj.Id = caseId;
            if(operation=='fund received'){
                caseobj.Tenant_not_received_funds__c=false;  
            }
            if(operation=='awaiting review')
            {
                caseobj.Status='Awaiting Review';    
            }
            else{
                caseobj.Hide_Grey_Side_Bar__c = true; 
            }
            update caseobj;
            List<Case> caseList = [select id,status,Resolved_Without_Adjudication_Reason__c from Case where Id = :caseId];
            Case c = caseList[0]; 
            if(c.Resolved_Without_Adjudication_Reason__c == 'Agreed by Tenant with AmountToTT in Repayment'
               || c.Resolved_Without_Adjudication_Reason__c == 'Agreed by Tenant without AmountToTT in Repayment'
               || c.Resolved_Without_Adjudication_Reason__c == 'Agreed by AGLL in Repayment'
               || c.Resolved_Without_Adjudication_Reason__c == 'Offer Accepted by Tenant'|| c.Resolved_Without_Adjudication_Reason__c == 'Offer Accepted by AGLL' || c.Resolved_Without_Adjudication_Reason__c == 'Agreed by AGLL in Self-Resolution'|| c.Resolved_Without_Adjudication_Reason__c == 'Agreed by Tenant without AmountToTT in Selfres'|| c.Resolved_Without_Adjudication_Reason__c == 'Agreed by Tenant in Self-Resolution'|| c.Resolved_Without_Adjudication_Reason__c == 'Agreed by AGLL in Evidence Gathering'|| c.Resolved_Without_Adjudication_Reason__c == 'Resolved by RE with AmountToTT in selfres')
            {
                EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
                EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper(c,c.Resolved_Without_Adjudication_Reason__c);
                helper.sendMailJetEmail(wrapper);
            }
                   
            return caseobj;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    

    @AuraEnabled(cacheable = true)
    public static List<Dispute_Item__c> getDidputeItemsOfCase(Id caseId){
        try {
            List<Dispute_Item__c> disputeItems = [select Id, Dispute__c, Type__c, Claimed_by_Landlord__c, Other_Reason__c FROM Dispute_Item__c where Dispute__c =:caseId];
            return disputeItems;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Case updateTenantfundstatus(Id caseId){
        case caseobj = new case ();
        
        try {
            caseobj.Id = caseId;
            caseobj.Tenant_not_received_funds__c = true;
            update caseobj;
            return caseobj;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}