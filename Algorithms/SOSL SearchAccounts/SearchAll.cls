public with sharing class SearchAll {

   private  List<List<sObject>>  searchResults;
   private List<Account> accounts;
   private List<Contact> contacts;
   private Id accountId;
   public String  searchText;
  
   public Id getAccountId(){
       return accountId;
   }
   public void setAccountId(Id accId){
       accountId=accId;
   }
  
    public PageReference View() {
     accountId = ApexPages.currentPage().getParameters().get('current_account_id');        
     
     PageReference pageRef = new PageReference('/apex/showAccount?id='+ accountId );
        pageRef.setRedirect(true);
        return pageRef;
    }
  
  public void setSearchText(String text){
      searchText = text;
  }
  public String  getSearchText(){
    return searchText;
  }
  
  public  List<Account> getAccounts(){
      return accounts;
  }
  
  public  List<Contact> getContacts(){
      return contacts;
  } 
   public PageReference search(){
       searchResults =[FIND :searchText 
in NAME FIELDS RETURNING    ACCOUNT(name,site),Contact(firstname,lastname,Email)
LIMIT 10];
       accounts    = (List<Account>)searchResults[0];
       contacts    = (List<Contact>)searchResults[1];
       return null;
   }
}


