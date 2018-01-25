/**
 * This class contains unit tests for validating the behavior of Trigger on Opportunity ,Opportunity line items
 * and the opportunity display page
 * */
@isTest 
public class OpportunityLineItemTriggerServiceTest {
   
 @testSetup
	private static void createTestData(){ 
	    List<PricebookEntry> pbList         = new  List<PricebookEntry>();
	    List<Product2> products             = new List<Product2>();
	    List<Opportunity> opplist           = new List<Opportunity>();
	    List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();  
	    
	    for(Integer i=0;i<10;i++){
	       opplist.add(new Opportunity(name='opp'+i ,stagename ='Prospecting',
	                                    closedate = System.today() )); 
	    } 
	    for(Integer i=0;i<10;i++){
	        products.add(new Product2(Name='product'+i,isActive=true)); 
	    } 
	    
	    insert opplist;
	    insert products; 
	    
	    for(Product2 eachProd: products ){
	        pbList.add(new PricebookEntry(unitprice=0.01,Product2Id=eachProd.Id,
	                                                Pricebook2Id=Test.getStandardPricebookId(),
                                                    isActive=true,UseStandardPrice = false));
	    }  
	   insert pbList; 
	   lineItems.add(new OpportunityLineItem(Product2=products[0],OpportunityId=opplist[0].Id,
	                                            PriceBookEntryId=pbList[0].Id,
	                                            quantity=10,totalprice=10000)) ; 
	   insert lineItems; 
	}
  
  /**
  *  This test method verifies the total product quantity on Opportunity during line item insert
  **/
  static testMethod void testTotalProductQtyOnOpptyOnInsert(){
    Test.startTest();
         Integer totalProductQty = 0;
         Product2 lineItemProduct2 = [select id,name from Product2 where name = :'product2'] ;
         PricebookEntry pb = [select id from PricebookEntry where Product2Id =:lineItemProduct2.id];
         
         List<Opportunity> opplist  = [select id,stagename,total_quantity__c,(select id,quantity,Product2.name 
                                                                from OpportunityLineItems )
                                            from Opportunity limit 1];
         totalProductQty = Integer.valueOf(opplist[0].total_quantity__c);
        
         //---Insert one more line item with quantity 100 and check the total quantity on Opportunity after insertion------//
         OpportunityLineItem lineItems =  new OpportunityLineItem(Product2=lineItemProduct2,
                                                OpportunityId=opplist[0].Id, 
	                                            quantity=100,totalprice=10000,
	                                             PriceBookEntryId=pb.Id) ;
         
         insert lineItems;
         
      Test.stopTest();  
      
       List<Opportunity> opplistAfter  = [select id,total_quantity__c,main_product__c 
                                                        from Opportunity where id =:opplist[0].id];
      
       System.assertEquals(opplistAfter[0].main_product__c ,'product2'  );
       System.assertEquals(opplistAfter[0].total_quantity__c ,totalProductQty + lineItems.quantity );
       
        
         
  }
  
  /**
  *  This test method verifies the total product quantity on Opportunity during line item update
  **/
  
  static testMethod void testTotalProductQtyOnOpptyOnUpdate(){
    Test.startTest();
         Integer totalProductQty = 0;
         String mainProductName ;
       
         List<Opportunity> opplist  = [select id,stagename,total_quantity__c,(select id,quantity,Product2.name 
                                                                from OpportunityLineItems )
                                            from Opportunity limit 1];
         totalProductQty = Integer.valueOf(opplist[0].total_quantity__c); 
         
         //---------Change the quantity of existing LineItem-----------//
         OpportunityLineItem currentLineItem = opplist[0].OpportunityLineItems;
         currentLineItem.quantity = 110;
         mainProductName=currentLineItem.Product2.name;
         update  currentLineItem;
          
      Test.stopTest();  
      
       List<Opportunity> opplistAfter  = [select id,total_quantity__c,main_product__c 
                                                from Opportunity where id =:opplist[0].id]; 
       System.assertEquals(opplistAfter[0].total_quantity__c ,currentLineItem.quantity ); 
       System.assertEquals(opplistAfter[0].main_product__c , mainProductName ); 
  }
  
  /**
  *  This test method verifies the total product quantity on Opportunity during line item deletion
  **/
  
  static testMethod void testTotalProductQtyOnOpptyOnDelete(){
    Test.startTest(); 
       
         List<Opportunity> opplist  = [select id,stagename,total_quantity__c,(select id,quantity,Product2.name 
                                                                from OpportunityLineItems )
                                            from Opportunity limit 1]; 
         
         //---------Delete the only LineItem and check the qty-----------//
         OpportunityLineItem currentLineItem = opplist[0].OpportunityLineItems; 
         delete  currentLineItem;
          
      Test.stopTest();  
      
       List<Opportunity> opplistAfter  = [select id,total_quantity__c,main_product__c 
                                                from Opportunity where id =:opplist[0].id]; 
       System.assertEquals(opplistAfter[0].total_quantity__c ,0 ); 
       System.assertEquals(opplistAfter[0].main_product__c , null ); 
  }
  
  
  /**
  *  This test method verifies that Opportunity With Lines cannot be deleted
  **/
  static testMethod void testDeletionOnOpptyWithLines(){
     //---- Fetch an opportnity record with line item-----//
     OpportunityLineItem oppLineItems  = [select id ,OpportunityId from OpportunityLineItem limit 1 ];
     List<Opportunity> opplist  = [select id,name from Opportunity where id=:oppLineItems.OpportunityId];
     
     Boolean hasError = false;
     String  errorMessage ='';
     try{
         delete opplist;
     }
     catch(Exception deleteExeption){
         hasError = true;
         errorMessage = deleteExeption.getMessage();
     }
     
     System.assertEquals(true,hasError);
     System.assert(errorMessage.contains('Cannot delete this  opportunity as product exists')); 
  }
  
  /**
  *  This test method verifies that Opportunity Without Lines could  be deleted
  **/
  static testMethod void testDeletionOnOpptyWithoutLines(){
     //---- Fetch an opportunity record with line item-----//
   Test.startTest();  
     Opportunity oppWithoutLine  = [select id,name from Opportunity where name = :'opp2'];
     Boolean hasError = false;
     String  errorMessage ='';
     try{
         delete oppWithoutLine;
     }
     catch(Exception deleteExeption){
         hasError = true;
         errorMessage = deleteExeption.getMessage();
     }
    Test.stopTest();   
    
     System.assertEquals(false,hasError);
     System.assertEquals( errorMessage,'');  
  }
  /**
  *  This test method verifies the SearchOpportunity page and controller class when the Opportunity has line items
  **/
  static testMethod void testSearchOpportunityPageWithLineItems(){
    Test.startTest(); 
      List<Apexpages.Message> successMsgs =new List<Apexpages.Message>();
      boolean sawSuccessMsg = false;
      PageReference pageRef = Page.SearchOpportunityPage;
      Test.setCurrentPage(pageRef); 
      SearchOpportunity searchPage = new SearchOpportunity();
      searchPage.searchTerm = 'product0';
      searchPage.searchOpp(); 
      successMsgs = ApexPages.getMessages();
      for(Apexpages.Message eachMsg:successMsgs){
        if (eachMsg.getDetail().contains('Success!!!!, Found')) sawSuccessMsg = true;
      }  
      
     Test.stopTest();   
       //---- Assert   there is  line item for the opportunity----------//
      system.assertNotEquals( searchPage.lineItems.size(), 0);
      //-----Verify that the success message is found-------//
      system.assert(sawSuccessMsg); 
      
  }
   /**
  *  This test method verifies the SearchOpportunity page and controller class when the Opportunity has no line items
  *  or no product is entered for searching
  **/
  static testMethod void testSearchOpportunityPageWithoutLineItems(){ 
     Test.startTest(); 
      List<Apexpages.Message> errorMsgs =new List<Apexpages.Message>();
      boolean sawError = false;
      PageReference pageRef = Page.SearchOpportunityPage;
      Test.setCurrentPage(pageRef); 
      SearchOpportunity searchPage = new SearchOpportunity();
      
      //------Verify the error message when no product is entered for searching----//
      searchPage.searchTerm = '';
      searchPage.searchOpp();
      
      errorMsgs = ApexPages.getMessages();
      for(Apexpages.Message eachMsg:errorMsgs){
        if (eachMsg.getDetail().contains('Please enter a product name')) sawError = true;
      }  
      
      //------Verify the error message when  the Opportunity has no line items----//
      //----  reset values------//
      errorMsgs = new List<Apexpages.Message>();
      sawError = false;
      
      searchPage.searchTerm = 'product3';
      searchPage.searchOpp();
      
      errorMsgs = ApexPages.getMessages();
      for(Apexpages.Message eachMsg:errorMsgs){
        if (eachMsg.getDetail().contains('No Opportunities found with this Product name')) sawError = true;
      }  
     Test.stopTest();  
     //---- Assert that there is no line item for the opportunity----------//
     system.assertEquals( searchPage.lineItems.size(), 0);
      //---- Assert that there is proper error message---------//
     system.assert(sawError); 
  }
  
}