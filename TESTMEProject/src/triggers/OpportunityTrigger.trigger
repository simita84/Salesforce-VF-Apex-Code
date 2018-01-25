trigger OpportunityTrigger on Opportunity (before delete) {
    /**
    *  This trigger will prevent the deletion of Opportunity if there are any line items added in it
    **/ 
    if(Trigger.isDelete && Trigger.isBefore){
       OpportunityTriggerService.checkLineItemsOnOppDeletion(Trigger.old);
    }

}