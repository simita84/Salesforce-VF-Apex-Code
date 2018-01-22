trigger AccountTrigger on Account (before insert,after insert) {
     
    // *********** Prevent duplicate accounts**********//
     if(Trigger.isBefore && Trigger.isInsert){
         Set<String> accountNames = new Set<String>();
         List<Account> accounts = [select id,name from Account];
         for(Account eachAcc : accounts){
            accountNames.add(eachAcc.name); 
         }
         
         for(Account eachNewAcc : Trigger.new){
            if(accountNames.contains(eachNewAcc.name)){
                //----Error shows on the account record-----//
                //eachNewAcc.addError('Duplicate Account found');
                
                // Error shows on the account name field
                eachNewAcc.name.addError('Duplicate Account found');
            }
         }
         
         
        
     }
    
    
    if(Trigger.isAfter && Trigger.isInsert){
       //AccountHandler.collectContacts(Trigger.new);
    }
    
}