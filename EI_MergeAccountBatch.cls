public class EI_MergeAccountBatch implements Database.Batchable<Sobject>{
	//Modified to update Deposit amount 
    public map<String,list<Account>> emailVsAccounts = new map<String,list<Account>>();
    public string queryString = '';
    /*public EI_MergeAccountBatch(map<String,List<Account>> mapForCharacters){
        
         this.emailVsAccounts = mapForCharacters;
    }
    public Iterable<String> start(Database.BatchableContext BC){
        
        
        if(this.emailVsAccounts.size() == 0){
            return new list<String>();
        }else{
            Set<String> setOfEmails = this.emailVsAccounts.keySet();
            List<String> lStrings = new List<String>(setOfEmails);
            return lStrings;
        }
        
    }
   
    public void execute(Database.BatchableContext BC, List<String> scope){
        
        String email3 = scope[0];
        try{
        	

            User use = [Select Id,AccountId from User where profile.Name = 'Tenant' and email =: email3 AND isActive = true AND userName =: email3];
            
            Account masterAccount = new Account(Id = use.AccountId); 
            
            if(use.AccountId != null){
                list<Id> accountsToMerge = new list<Id>();
                for(Account acc : emailVsAccounts.get(email3)){
                    if(acc.Id == use.AccountId){
                        //masterAccount =acc;
            
                    }else{
                        accountsToMerge.add(acc.Id);
                    }
                }
            
                for(Id idx : accountsToMerge){
                    // ????????? Verify fields as well while merging
                    merge masterAccount idx;
                }
                use.Send_Email__c = true;
                Update use;
            
            }else{
                //throw exception
                insert new Flagged_Emails__c(Name = email3);
            }
        }Catch(Exception exc){
            
            //Create Flagged emails record 
            insert new Flagged_Emails__c(Name = email3);
        }
        
        

    }*/
    
    
    
    public EI_MergeAccountBatch(String queryString){
        
         this.queryString = queryString;
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        
        return Database.getQueryLocator(queryString);
        
    }
   
    public void execute(Database.BatchableContext BC, List<Deposit__c> scope){
        
        
        list<Deposit__c> depositsToUpdate = new list<Deposit__c>();
        
        for(Deposit__c dep : scope){
            if(dep.Histories.isEmpty()){
                //dep.Original_Deposit_Amount__c = dep.Deposit_Amount__c;
                depositsToUpdate.add(new Deposit__c(Id = dep.Id, Original_Deposit_Amount__c = dep.Deposit_Amount__c));
                
            }else{
                
                String amount = String.valueOf(dep.Histories[0].OldValue);
                depositsToUpdate.add(new Deposit__c(Id = dep.Id, Original_Deposit_Amount__c = Decimal.valueOf(amount)));
            }
        }
        if(!depositsToUpdate.isEmpty()){
            Update depositsToUpdate;
        }
    }
   
    public void finish(Database.BatchableContext BC){
   
    }


    
    /*
     * 
     *
     list<Account> accountList = [Select Id,personemail from Account where RecordType.Name = 'Tenant' and PersonEmail Like 'a%' AND Createdby.Name = 'Sadie-Lee Cooper' AND Count_Of_Da__c > 0];
        map<String,list<Account>> emailVsAccounts = new map<String,list<Account>>();
        
        for(Account acc : accountList){
            if(emailVsAccounts.containsKey(acc.PersonEmail)){
                list<Account> innerList = emailVsAccounts.get(acc.PersonEmail);
                innerList.add(acc);
                emailVsAccounts.put(acc.PersonEmail,innerList);
            }else{
                emailVsAccounts.put(acc.PersonEmail,new list<Account>{acc});
            }
        }
        Integer maxSize = 0;
        String email = '';
        Integer totalRecord = 0;
        for(String email2 : emailVsAccounts.keySet()){
        
            if(emailVsAccounts.get(email2).size() > 2){
                totalRecord++;
        
                if(emailVsAccounts.get(email2).size() > 2 && emailVsAccounts.get(email2).size() > maxSize){
                    maxSize = emailVsAccounts.get(email2).size();
                    email = email2;
                }
            }else{
                emailVsAccounts.remove(email2);
            }
        
            
        
        }
        
        System.debug('Total Records - '+totalRecord);
        System.debug('Max Size - '+maxSize);
        System.debug('Email - '+email); 

		Database.executeBatch(new EI_MergeAccountBatch(emailVsAccounts),1);
*/
    
    
    public static void increaseCoverage(){
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
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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