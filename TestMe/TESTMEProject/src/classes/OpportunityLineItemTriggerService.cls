/**
* This is a service class for handles various trigger cases on OpportunityLineItem
* Author : Simi Tresa Antony
**/
public with sharing class  OpportunityLineItemTriggerService {
  
  public class handleTriggerException extends Exception {}  
  
  /**
  * Following method   handles the total quantiy and main product on 
  * Opportunity during insert on OpportunityLineItem 
  **/ 
  public static  void  handleInsertOpptyLines(List<OpportunityLineItem> currentOpptyLineItems, 
                                              Map<Id,Opportunity> mapOppsChanged ,
                                              Map<Id,String> mapMainProductOpp,
                                              Map<Id,Integer> mapTotalQtyOnOpp){
                                                   
        Map<Id,Opportunity> oppMapAfterInsert = new Map<Id,Opportunity>();
        
        for(OpportunityLineItem eachLineItem : currentOpptyLineItems ){ 
             Opportunity existingOpp = mapOppsChanged.get(eachLineItem.OpportunityId);
             //----If null get the value from aggregate query--------//
             existingOpp.total_quantity__C =  mapTotalQtyOnOpp.get(eachLineItem.OpportunityId) ;
             //--------Check id there is another lineitem that has more quantity, else put the current one----//
             existingOpp.main_product__c   =  mapMainProductOpp.get(eachLineItem.OpportunityId) != '' ?
                                                mapMainProductOpp.get(eachLineItem.OpportunityId): eachLineItem.name; 
             oppMapAfterInsert.put(existingOpp.id,existingOpp); 
        }
       
       try{
           update oppMapAfterInsert.values(); // try Database.SaveResult Todo
            //--To do - If you want to handle errors in bulk---//
            //Database.SaveResult[] updatedResults = Database.update(oppMapAfterInsert.values(),false);
       }
       catch(Exception updateException){ 
          throw new handleTriggerException('Update Failed while inserting the opportunity due to '
                                    +updateException.getMessage()); // Use Custom Label To Do 
       } 
  }
  
  /**
  * Following method   handles the total quantiy and main product 
  * on Opportunity during update on OpportunityLineItem  
  **/ 
  public  static  void  handleUpdateOpptyLines( List<OpportunityLineItem> currentOpptyLineItems, 
                                                Map<Id,OpportunityLineItem> mapOldLineItems,
                                                Map<Id,Opportunity> mapOppsChanged ,
                                                Map<Id,String> mapMainProductOpp){ 
                                                    
        List<Opportunity> oppListAfterUpdate = new List<Opportunity>();
        
        for(OpportunityLineItem eachLineItem : currentOpptyLineItems){ 
         Opportunity existingOpp = mapOppsChanged.get(eachLineItem.OpportunityId); 
         existingOpp.total_quantity__C = existingOpp.total_quantity__C - mapOldLineItems.get(eachLineItem.Id).quantity 
                                                + eachLineItem.quantity  ;
         
          //--------Check id there is another lineitem that has more quantity, else put the current one----//
         existingOpp.main_product__c   =  mapMainProductOpp.get(eachLineItem.OpportunityId) != '' ?
                                            mapMainProductOpp.get(eachLineItem.OpportunityId): eachLineItem.name;
         
         
         oppListAfterUpdate.add(existingOpp);
        }
        try{
         upsert oppListAfterUpdate;
        }
          catch(Exception updateException){ 
            throw new handleTriggerException('Update Failed while inserting the opportunity due to '
                                    +updateException.getMessage()); // Use Custom Label To Do 
       } 
      
  }
  /**
  * Following method   handles the total quantiy and main product on 
  * Opportunity during deletion of OpportunityLineItem/s  
  **/ 
   public  static void  handleDeleteOpptyLines(List<OpportunityLineItem> oldOpptyLineItems, 
                                               Map<Id,Opportunity> mapOppsChanged ,
                                               Map<Id,String> mapMainProductOpp ){
         List<Opportunity> oppListAfterDelete = new List<Opportunity>();
         
        for(OpportunityLineItem eachLineItem : oldOpptyLineItems){ 
         Opportunity existingOpp = mapOppsChanged.get(eachLineItem.OpportunityId); 
         existingOpp.total_quantity__C = existingOpp.total_quantity__C - eachLineItem.quantity  ;
         //--------Check id there is another lineitem that has more quantity, else put the current one----//
         existingOpp.main_product__c   =  mapMainProductOpp.get(eachLineItem.OpportunityId) != '' ?
                                            mapMainProductOpp.get(eachLineItem.OpportunityId): eachLineItem.name;
         
         oppListAfterDelete.add(existingOpp);
        }
       try{
        upsert oppListAfterDelete;
       }
          catch(Exception updateException){ 
            throw new handleTriggerException('Update Failed while inserting the opportunity due to '
                                    +updateException.getMessage()); // Use Custom Label To Do 
       } 
      
  }
 
}