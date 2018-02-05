/**
* This is the trigger that handles all the OpportunityLineItem  transactions
* Author : Simi Tresa Antony
**/

trigger OpportunityLineItemTrigger on OpportunityLineItem (after insert,after update , after delete) { 
    
    //-- Used to collect all the ids of the changing OpportunityLineItem ---//
    Set<Id> currentOpptyIds = new Set<Id>(); 
    
    
     //-- Used to collect all the ids of  OpportunityLineItem inserted and updated---//
     if( (Trigger.isInsert && Trigger.isAfter) || (Trigger.isUpdate && Trigger.isAfter) ){ 
     
        for(OpportunityLineItem eachLineItem : Trigger.new ){
            currentOpptyIds.add(eachLineItem.OpportunityId);
           
        } 
     }
       //-- Used to collect all the ids of  OpportunityLineItem deleted---//
     else if(Trigger.isDelete && Trigger.isAfter){
        
        for(OpportunityLineItem eachLineItem : Trigger.old ){
            currentOpptyIds.add(eachLineItem.OpportunityId);
        }
     } 
     
     //---- This map is used to find the total quantity and main product on all the  opportunities ---//
     Map<Id,Opportunity> mapOppsChanged = new  Map<Id,Opportunity>([select id,total_quantity__C ,main_product__c
                                                                     from Opportunity 
                                                                     where id in :currentOpptyIds]);
     
     /**
      * Following code is to find main product  on opportunity by quantity.
      **/
     
     //--- Map to store main product with opportunity Id------//
     Map<Id,String> mapMainProductOpp = new  Map<Id,String>();
     //------ The top lines item based on quantity is fetched per opportunity ----------// 
     List<Opportunity> mainProductOppList = [select id,(select Product2.name,quantity 
                                                        from OpportunityLineItems order by quantity desc limit 1)
                                                        from opportunity ]; 
     
     for(Opportunity eachOpp: mainProductOppList){ 
         if(eachOpp.OpportunityLineItems.size()>0){
            mapMainProductOpp.put(eachOpp.id,eachOpp.OpportunityLineItems[0].Product2.name);
         }
         //----Opportunities without line items----//
         else{
            mapMainProductOpp.put(eachOpp.id,''); 
         } 
     }
     
     /**
      * Following code is to find sum of quantities on opportunity based on  product on quantity.
      **/
      
     List<AggregateResult> totalQtyOnOpp = [select sum(quantity) sumOfQty ,  OpportunityId 
                                                    from OpportunityLineItem  
                                                group by OpportunityId ]; 
     Map<Id,Integer> mapTotalQtyOnOpp = new  Map<Id,Integer>(); 
     
     for(AggregateResult eachAgg: totalQtyOnOpp ){
         mapTotalQtyOnOpp.put((Id)eachAgg.get('OpportunityId'),Integer.valueOf(eachAgg.get('sumOfQty')) ); 
     } 
     
     /**
      * Following code would handle the total quantity and main product on Opportunity during insert,update & delete
      **/
    
    //------New Opportunity Product is added---------//
    if(Trigger.isInsert && Trigger.isAfter){  
        OpportunityLineItemTriggerService.handleInsertOpptyLines(Trigger.new,   mapOppsChanged , 
                                                                 mapMainProductOpp,  mapTotalQtyOnOpp); 
    } 
    //------Opportunity Product is updated---------//
    if(Trigger.isUpdate && Trigger.isAfter){ 
        OpportunityLineItemTriggerService.handleUpdateOpptyLines( Trigger.new,Trigger.oldMap,  mapOppsChanged ,  
                                                                  mapMainProductOpp); 
    } 
    //------Opportunity Product is deleted--------- 
    if(Trigger.isDelete && Trigger.isAfter){ 
         OpportunityLineItemTriggerService.handleDeleteOpptyLines(Trigger.old,mapOppsChanged ,mapMainProductOpp); 
        
    } 
} 
    // To do
    // 1.make the total quantity read only