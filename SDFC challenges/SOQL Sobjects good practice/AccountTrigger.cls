trigger AccountTrigger on Account (before insert,after insert) {
	 
    if(Trigger.isAfter && Trigger.isInsert){
       AccountHandler.collectContacts(Trigger.new);
    }
    
}

public class AccountHandler {
    public static Map<Id,List<Contact>>  collectContacts(List<Account> changedAccts){
         Map<Id,List<Contact>> accContactMap = new Map<Id,List<Contact>>();
        
        List<Contact> consToUpdate = new List<Contact>();
        
        List<Account> singleQuery = [select id,name,(select id,lastname from Contacts) 
                            			from Account where id in :changedAccts]; //20000
        
        for(Account acc :singleQuery){
             consToUpdate.add(acc.Contacts);
        } 
        update consToUpdate;//20000
        
        for(Account twoHundAccts : [select id,name,(select id,lastname from Contacts) 
                             			from Account where id in :changedAccts]){
           						// accContactMap.put(acct.id,acct.contacts);
           consToUpdate.add(twoHundAccts.Contacts);
        } 	
        update consToUpdate;
        
        //200 * 100 
        for(List<Account> acctList : [select id,name,(select id,lastname from Contacts) 
                            			from Account where id in :changedAccts]){
                         
           for(Account eachAcc:acctList ){
               consToUpdate.add(eachAcc.Contacts);                                  
           }
          
           update consToUpdate;
        } 
        	 
        return accContactMap; 
    }
}
