 global with sharing class FetchAccountsController {
    
    public static Account account{get;set;}   
    public  String accountName{get;set;}
    
    public FetchAccountsController(){
    } 

    @RemoteAction 
    global static Account  getAccount(String accountName){ 
    
 account = [SELECT Id,Name ,Site 
      FROM ACCOUNT 
WHERE name=:accountName];
     return account;  
   }
 } 

