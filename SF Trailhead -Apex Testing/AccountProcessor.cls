public class AccountProcessor {
   
    @future
    public static void countContacts(List<Id> accIds){ 
       List<Account> newAccList = new  List<Account>();
       List<Account> accts =  [select id, name,(select id 
                                                from Contacts) 
                               				from Account where id in :accIds];
       
        for(Account eachAcc:accts ){
           Integer contactsSize =  eachAcc.Contacts == null ? 0 : eachAcc.Contacts.size();
             eachAcc.Number_of_Contacts__c = contactsSize;
            newAccList.add(eachAcc);
        }
        
        Database.update(newAccList,false);
    }
}