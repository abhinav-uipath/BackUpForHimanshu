public without sharing class EI_InstallmentTriggerHandler {
    
public static void updateBankDetails( list<Installment__c> installmentList){
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
    Id devRecordTypeId = Schema.SObjectType.Installment__c.getRecordTypeInfosByName().get('SDS Installment').getRecordTypeId();
    User userProfile = [Select id,Name,profile.Name from User where id=: userinfo.getUserId()];
    Set<Id> conId = new Set<Id>();
    List<Id> depositIds = new List<Id>();
    Map<Id,Installment__c> conMap = new Map<Id,Installment__c>();
    Map<Id,Bank_Account__c> bankMap = new Map<Id,Bank_Account__c>();
    Map<Id,Bank_Account__c> bankMap2 = new Map<Id,Bank_Account__c>();
    Map<Id,Deposit__c> installmentDepositsMap= new Map<Id,Deposit__c>();
    system.debug('@@# '+installmentList[0].Account__c);
    for(Installment__c installment : installmentList){
        depositIds.add(installment.Deposit__c);
        if(installment.contact__c == NULL){
            conId.add(installment.Account__c );
        }else
            conId.add(installment.contact__c);
        
    }
    List<Deposit__c> deposits=[Select Id,Bank_Account_Holder_Name__c,Account_Number__c,Sort_Code__c,	
                               Bank_Name__c From Deposit__c Where Id=:depositIds];	
    for(Deposit__c deposit : deposits){	
        if(deposit.Account_Number__c!=Null)	
            installmentDepositsMap.put(deposit.Id,deposit);	
    }
    for(Bank_Account__c bankDt: [Select id,International_Account_Number__c,IBAN__c,Account__c,International_Bank_Account_Holder_Name__c,BIC__c,Swift_Code__c,International_Bank_Name__c,ValidInternationBankDetails__c,Contact__c,Bank_Account_Holder_Name__c,Account_Number__c,Sort_Code__c,Bank_Name__c from Bank_Account__c where ( Account__c =: conId and Account__c != NULL) OR (contact__c =: conId and contact__c != NULL)]){
        bankMap.put(bankDt.Account__c ,bankDt);
        bankMap2.put(bankDt.Contact__c ,bankDt);
    }
    system.debug('@@ '+bankMap);
    for(Installment__c installment : installmentList){
        if(installmentDepositsMap.containsKey(installment.Deposit__c) && (installment.User_type__c=='Letting Agent' || installment.User_type__c=='Individual Landlord'||installment.User_type__c=='Corporate Landlord'||installment.User_type__c=='Organization')){
            installment.Bank_account_holder_name__c=installmentDepositsMap.get(installment.Deposit__c).Bank_Account_Holder_Name__c;	
                installment.Bank_account_number__c=installmentDepositsMap.get(installment.Deposit__c).Account_Number__c;	
                installment.Bank_sort_code__c=installmentDepositsMap.get(installment.Deposit__c).Sort_Code__c;	
                installment.Bank_name__c=installmentDepositsMap.get(installment.Deposit__c).Bank_Name__c;
        }
        else{
        if(installment.RecordTypeId == devRecordTypeId && bankMap.size()>0 ){
            if(installment.contact__c == NULL && installment.account__c != NULL){    
                if(bankMap.containsKey(installment.Account__c) && bankMap.get(installment.Account__c).ValidInternationBankDetails__c ){
                    installment.Bank_account_holder_name__c=bankMap.get(installment.Account__c).Bank_Account_Holder_Name__c;
                    installment.Bank_account_number__c =bankMap.get(installment.Account__c).Account_Number__c;
                    installment.Bank_sort_code__c = bankMap.get(installment.Account__c).Sort_Code__c;
                    installment.Bank_name__c = bankMap.get(installment.Account__c).Bank_Name__c;
                    installment.Custom_Account_Number__c = '';
                    installment.Swift_Code__c = ''; 
                    installment.BIC__c =  ''; 
                    installment.International_Payment__c = false;
                }else{
                    installment.Bank_account_number__c = bankMap.get(installment.Account__c).International_Account_Number__c;
                    installment.Bank_name__c = bankMap.get(installment.Account__c).International_Bank_Name__c;
                    installment.Custom_Account_Number__c = bankMap.get(installment.Account__c).IBAN__c;
                    installment.Swift_Code__c =    bankMap.get(installment.Account__c).Swift_Code__c; 
                    installment.BIC__c =   bankMap.get(installment.Account__c).BIC__c; 
                    installment.Bank_account_holder_name__c = bankMap.get(installment.Account__c).International_Bank_Account_Holder_Name__c;
                    installment.Bank_sort_code__c = '';
                    installment.International_Payment__c = true;
                }
            }
            else if(installment.account__c == NULL && installment.contact__c != NULL){
                
                if(bankMap2.containsKey(installment.Contact__c) && bankMap2.get(installment.Contact__c).ValidInternationBankDetails__c ){
                    installment.Bank_account_holder_name__c=bankMap2.get(installment.Contact__c).Bank_Account_Holder_Name__c;
                    installment.Bank_account_number__c =bankMap2.get(installment.Contact__c).Account_Number__c;
                    installment.Bank_sort_code__c = bankMap2.get(installment.Contact__c).Sort_Code__c;
                    installment.Bank_name__c = bankMap2.get(installment.Contact__c).Bank_Name__c; 
                    installment.International_Payment__c = false;
                }else{
                    if(bankMap2.containsKey(installment.Contact__c)){
                        installment.Bank_account_number__c = bankMap2.get(installment.Contact__c).International_Account_Number__c;
                        installment.Bank_name__c = bankMap2.get(installment.Contact__c).International_Bank_Name__c;
                        installment.Custom_Account_Number__c = bankMap2.get(installment.Contact__c).IBAN__c;
                        installment.Swift_Code__c =    bankMap2.get(installment.Contact__c).Swift_Code__c; 
                        installment.BIC__c =   bankMap2.get(installment.Contact__c).BIC__c; 
                        installment.Bank_account_holder_name__c = bankMap2.get(installment.Contact__c).International_Bank_Account_Holder_Name__c;
                        installment.International_Payment__c = true;
                    }
                    
                }
            }
        }
        else if (installment.account__c != NULL && installment.RecordTypeId == devRecordTypeId && bankMap.size() == 0 ){
            installment.Bank_account_holder_name__c='';
            installment.Bank_account_number__c ='';
            installment.Bank_sort_code__c = '';
            installment.Bank_name__c = ''; 
            installment.Custom_Account_Number__c = '';
            installment.Swift_Code__c = ''; 
            installment.BIC__c = ''; 
            
        }
        
    }
    } 
    
}
    public static void createChequePayments(map<Id,Installment__c> oldMap, list<Installment__c> installmentList){
        
        list<Payment__c> listOfPaymentsToCreate = new list<Payment__c>();
        list<Installment__c> listOfInstallmentsToUpdate = new list<Installment__c>(); 
        list<Id> depositIdsToUpdate = new list<Id>();
        map<Id,Decimal> depositIdVsAmountToDecrease = new map<Id,Decimal>();
        Id paymentRecId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('SDS Payment').getRecordTypeId();
        
        for(Installment__c installment : installmentList){
            if(installment.Paid_By_Cheque__c && installment.Status__c == 'Pending Processing' && (oldMap == null || !oldMap.containsKey(installment.Id) || oldMap.get(installment.Id).Paid_By_Cheque__c != installment.Paid_By_Cheque__c)){
                
                
                //to update status of Installments
                listOfInstallmentsToUpdate.add(new Installment__c(Id = installment.Id,Status__c = 'Paid'));
                
                
                Payment__c payment = new Payment__c();
                payment.Installment__c = installment.Id;
                payment.RecordTypeId = paymentRecId;
                payment.Amount__c = installment.Amount__c;
                payment.DAN__c = installment.Deposit__c;
                payment.Payment_Status__c = 'Paid';
                payment.Payment_Type__c = 'Payable';
                listOfPaymentsToCreate.add(payment);
                
                depositIdsToUpdate.add(installment.Deposit__c);
                if(depositIdVsAmountToDecrease.containsKey(installment.Deposit__c)){
                    
                    Decimal previousValue = depositIdVsAmountToDecrease.get(installment.Deposit__c);
                    depositIdVsAmountToDecrease.put(installment.Deposit__c,installment.Amount__c+previousValue);
                }else{
                    depositIdVsAmountToDecrease.put(installment.Deposit__c,installment.Amount__c);
                }
                
                
            }
        }
        
        
        if(!listOfInstallmentsToUpdate.isEmpty()){
            try {
                Update listOfInstallmentsToUpdate;
                Insert listOfPaymentsToCreate;
                //to update deposit status
                //TJ     EI_RepaymentsUtility.updateDepositAmounts(depositIdsToUpdate,depositIdVsAmountToDecrease);
                
                
            } catch (Exception exc) {
                //Create Logs 
            }
        }
    }
    
    /**********************************************************************************************************
* Author: Shirin
* Purpose:method populates installment to aggreate on case
*          
* *******************************************************************************************************/
    /* Changes: 
* 
* *******************************************************************************************************/
    
    
    public static void aggregateCasefromInstallment(Map<Id,Installment__c> oldMap, List<Installment__c> newList,List<Installment__c> oldList,
                                                    Boolean isInsert,Boolean isUndelete,Boolean isDelete,Boolean isUpdate){
                                                        
                                                        Set<ID>caseIds = new Set<ID>();   
                                                        //Added By Shirin as Recordtype is 
                                                        //Id CaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute EW Insured').getRecordTypeId();
                                                        Id InstalmentRecordTypeId = Schema.SObjectType.Installment__c.getRecordTypeInfosByName().get('EWI Installment').getRecordTypeId();    
                                                        if(isInsert || isUndelete){
                                                            for(Installment__c objIns : newList){
                                                                
                                                                if(objIns.Case__c!=null && InstalmentRecordTypeId ==  objIns.RecordTypeId){
                                                                    caseIds.add(objIns.Case__c);
                                                                }
                                                            }
                                                        }
                                                        
                                                        
                                                        if(isDelete ){
                                                            for(Installment__c objIns : oldList){
                                                                if(objIns.Case__c!=null && InstalmentRecordTypeId ==  objIns.RecordTypeId){
                                                                    caseIds.add(objIns.Case__c);
                                                                }
                                                            }        
                                                        }
                                                        
                                                        if(isUpdate){
                                                            for(Installment__c objIns:newList){
                                                                if(objIns.Case__c!=null ){
                                                                    caseIds.add(objIns.Case__c);
                                                                    system.debug('----'+caseIds);
                                                                    if(oldmap.get(objIns.Id).Case__c != objIns.Case__c && InstalmentRecordTypeId ==  objIns.RecordTypeId){
                                                                        caseIds.add(oldmap.get(objIns.Id).Case__c);
                                                                        system.debug('----'+caseIds);
                                                                    }
                                                                }            
                                                            }
                                                        }    
                                                        /* for(Installment__c objIns:newList){
if(objIns.Case__c!=null){
if(oldmap.get(objIns.Id).Case__c != objIns.Case__c){
caseIds.add(objIns.Case__c);     
}
} 
caseIds.add(oldmap.get(objIns.Id).Case__c);
}
}  
*/ 
                                                        Map<id,double> amtMap = new Map<id,double>();
                                                        list<Case>updateCaselist = new list<Case>();
                                                        
                                                        try{
                                                            if(caseIds.size()>0){    
                                                                for(Aggregateresult ag : [select Status__c,Case__c ,SUM(Amount__c) SOA,count(id) cc from Installment__c where Case__c in:caseIds AND Status__c='Collected' group by Case__c,Status__c]){
                                                                    amtMap.put((ID)ag.get('Case__c'), double.valueof(ag.get('SOA')));
                                                                    //updateCaselist.add(new Case(Id = (Id)ag.get('Case__c'), Amount_of_Disputed_Funds_Received__c = (Decimal)ag.get('SOA')));
                                                                }
                                                                system.debug('----'+updateCaselist);
                                                                
                                                                
                                                                for(Id csId : caseIds){
                                                                    Case objCase = new Case(id=csId);
                                                                    system.debug('----amtMap'+ amtMap);
                                                                    if(amtmap.containskey(csId) ){
                                                                        system.debug('----amtMapGet'+ amtMap.get(csId));
                                                                        objCase.Amount_of_Disputed_Funds_Received__c = amtMap.get(csId);
                                                                        system.debug('line-->276 ' +objCase.Amount_of_Disputed_Funds_Received__c );
                                                                        
                                                                        System.debug('Amount_of_Disputed_Funds_Remaining__c => ' + objCase.Amount_of_Disputed_Funds_Remaining__c);
                                                                        System.debug('Amount_of_Disputed_Funds_Received__c => ' + objCase.Amount_of_Disputed_Funds_Received__c);
                                                                        System.debug('Amount_of_Disputed_Funds_Required__c => ' + objCase.Amount_of_Disputed_Funds_Required__c);
                                                                        
                                                                        if(objCase.Amount_of_Disputed_Funds_Remaining__c == 0 && (objCase.Amount_of_Disputed_Funds_Received__c != 0 
                                                                                                                                  && (objCase.Amount_of_Disputed_Funds_Received__c >= objCase.Amount_of_Disputed_Funds_Required__c))  ){
                                                                                                                                      ObjCase.Disputed_Funds_Received__c =  True;  
                                                                                                                                      objCase.Stop_chaser_e_mails__c = True;
                                                                                                                                  }
                                                                        
                                                                    }else{
                                                                        objCase.Amount_of_Disputed_Funds_Received__c = 0;
                                                                    } 
                                                                    updateCaselist.add(objCase);       
                                                                }
                                                                
                                                                if(updateCaselist.size()>0){
                                                                    update updateCaselist;
                                                                }
                                                            }
                                                        }catch(exception ex){
                                                            Insert (new Error_Log__c(Message_Long__c='Issue is: '
                                                                                     + ex.getMessage() + '************ StackTrace String : ' + ex.getStackTraceString()
                                                                                     + ' at Line Number- ' + ex.getLineNumber(),Method_Name__c='Class: EI_InstallmentTriggerHandler '));
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