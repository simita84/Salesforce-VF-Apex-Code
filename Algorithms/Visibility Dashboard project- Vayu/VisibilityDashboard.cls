public class nestedqueryexample4
{ 
    
  // Current business id passed	
  public Id current_business{get; set;} 
  
  public List<Product_Custom__c> products;
    
  public List<Product_Custom__c> getProducts(){
        return products;
  }
  
  public List<Customer__c> getCustomers()
  {
      List<Customer__c> customers = [SELECT id,Customer__c.Name,   

Customer__c.Theater__c,
 Total_Visibility__c,
               (SELECT id, Business__c.name,
                           Business__c.Total_Products__c 
                           FROM Customer__c.Businesses__r)
                  FROM Customer__c];

      return customers;
                         
  }
 public  PageReference setProducts() {
          
     products = [SELECT Name, Marketing_Commit__c,Total_Visibility_per_product__c 
                        FROM Product_Custom__c 
                        WHERE Product_Custom__c.Business__r.id=:current_business];
         return null;
        
    }

    
}
 