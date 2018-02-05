/**
*   This Apex class has methids that help user search by product name 
*   and  to  get all the opportunities where they are added 
*   Author Simi Tresa Antony 
**/
 
public class SearchOpportunity {
    
    public  String searchTerm {get;set;} 
    public  Boolean hasLineItems {get;set;} 
    public  List<Opportunity> lineItems {get;set;}
    public  String searchInput;
    
    public SearchOpportunity(){
       hasLineItems = false;
    }
    
    public Pagereference searchOpp(){ 
        
        String searchInput =  searchTerm.toLowerCase().trim();
        Map<Id,opportunity> oppList = new Map<Id,opportunity>(); 
        
        //---- Assuming strict search using complete product name -----------//
        if(searchInput !=''){ 
          //--------- Search for the products in line items to find matching opportunity and product ------//
          List<OpportunityLineItem> querylineItems  = [select opportunity.id,opportunity.name,opportunity.amount,
                                                            opportunity.stagename, opportunity.main_product__c
                                                        from OpportunityLineItem  
                                                        where product2.name = :searchInput];  
                                                        
          //------The previous step has duplicate opportunities, trying to remove duplicates using Map----------//
          for(OpportunityLineItem eachItem : querylineItems){
               oppList.put(eachItem.opportunity.id,new Opportunity(id = eachItem.opportunity.id,
                                                       name=eachItem.opportunity.name,
                                                       amount=eachItem.opportunity.amount,
                                                       stagename = eachItem.opportunity.stageName, 
                                                       main_product__c = eachItem.opportunity.main_product__c));
          }
           
          lineItems = oppList.values();  
           
          hasLineItems = lineItems.size() > 0 ? true : false; 
          
       
           
          if(lineItems.size() == 0){
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 
                    'No Opportunities found with this Product name ')); 
    
          }else {
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 
                    'Success!!!!, Found ' + lineItems.size() + ' opportunities using product '+ searchInput));
          } 
           
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 
                'Please enter a product name '));  
        }
       
        return null;
    }
}