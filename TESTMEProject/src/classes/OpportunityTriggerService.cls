/**
 *  Author : Simi Tresa Antony
**/
public class OpportunityTriggerService {
    
    /** This method will prevent the deletion of Opportunity if there 
     * are any opportunity product added to it.
    */    
    public static  void checkLineItemsOnOppDeletion(List<Opportunity> deletedOpps){
       //-- This map if used to store the Opportunity Vs its line Item size----//
       Map<Id,Integer> mapOppLineItems = new Map<Id,Integer>();
       
       //--- Query to see any lines items added to the opportunity, need to return only one line item---//
       List<Opportunity> existingOpps =   [select id ,(select id from OpportunityLineItems limit 1)
                                                from Opportunity  where id in :deletedOpps];
        
        for(Opportunity eachOpp :  existingOpps){
            mapOppLineItems.put(eachOpp.id,eachOpp.OpportunityLineItems.size());
        }
       
       //Prevent the deletion of Opportunity if there are any opportunity product are added to it. 
        for(Opportunity eachOpp :  deletedOpps){
            if(mapOppLineItems.get(eachOpp.id)>0){
                eachOpp.addError('Cannot delete this  opportunity as product exists');
                // This error message could be moved to Custom Label if time permits
            }
        }     
    }
        
}