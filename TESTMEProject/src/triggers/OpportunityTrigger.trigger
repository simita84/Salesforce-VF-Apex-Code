/**
 * This trigger will prevent the deletion of Opportunity if there are any line items added in it
 *  Author : Simi Tresa Antony
**/
trigger OpportunityTrigger on Opportunity (before delete) {
  
    if(Trigger.isDelete && Trigger.isBefore){
       OpportunityTriggerService.checkLineItemsOnOppDeletion(Trigger.old);
    }

}