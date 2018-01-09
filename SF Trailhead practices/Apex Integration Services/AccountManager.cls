
@RestResource(urlMapping='/Accounts/*/contacts')
global with sharing Class AccountManager { 
  @httpGet
  global static Account getAccount(){ 
     RestRequest request = RestContext.request; 
     AccountResponse accResp ;  
     Pattern MyPattern = Pattern.compile('/Accounts/(\\w+)/contacts');
     Matcher MyMatcher = MyPattern.matcher(request.requestUri);
             MyMatcher.matches(); 
     //String accId        = MyMatcher.group(1);    
     String accId = request.requestURI.substring(request.requestURI.lastIndexOf('/')-18,
          request.requestURI.lastIndexOf('/'));
      
     
     List<Account> accts = [select id,name,(select id,lastname from Contacts) 
                                from Account where id =:accId];  
     if(accts.size()>0){
         //new AccountResponse(accts[0], accts[0].Contacts, true); 
     }
     
     return accts[0];
    //return accResp;
      
  } 
  
  /*global Class AccountResponse{
      Account accnt;
      List<Contact> conts;
      Boolean success;
      public AccountResponse(Account account,List<Contact> contacts,Boolean success){
          this.accnt = account;
          this.conts = contacts;
          this.success = success;
      }
  }*/
}
// /services/apexrest/Accounts/0011a00000GKJ5b/contacts 


@isTest
public class AccountManagerTest {
  
  @testSetup
  private static void setupData() {
      
        Account acc = new Account(name='Genetech Inc');
        insert acc;
        system.debug(acc);
        
        List<Contact> contacts = new List<Contact>();
        Contact Greg = new Contact(Lastname='Greg'); 
                Greg.account= acc;
        Contact Seirra = new Contact(Lastname = 'Seirra'); 
                Greg.account= acc; 
        contacts.add(Greg); contacts.add(Seirra);
        system.debug(contacts);
        insert contacts; 
        system.debug(contacts);
  }
  
  static testMethod void verifyAccountManagerApi(){
        
        List<Account> accts = [select id,name,(select id,lastname from Contacts) from Account];
        system.debug(accts);
        
        RestRequest request = new RestRequest();
        request.requestUri =
           ''+ URL.getSalesforceBaseUrl().toExternalForm() +'/services/apexrest/Accounts/'+accts[0].Id+'/contacts'; 
         //https://simi-dev-ed.my.salesforce.com   
        request.httpMethod = 'GET';
        RestContext.request = request;
        // Call the method to test
       // AccountManager.AccountResponse accResp = AccountManager.getAccount();
        System.assertEquals( AccountManager.getAccount().name ,'Genetech Inc');
      
      
  }
}