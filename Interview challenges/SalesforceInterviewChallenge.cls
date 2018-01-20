trigger ProdAllocTrigger on ProductionAllocation__c (after insert,before update) {
   
   //---- TD Move to Handler Class---//
   if(Trigger.isInsert || Trigger.isUpdate){ 
        List<AggregateResult>  alloctions = [select sum(AllocationPercent__c) perc,ParentProd__c 
                                                from ProductionAllocation__c 
                                                group by ParentProd__c];
       Map<id,Decimal> allocMap = new   Map<id,Decimal>();
      
       for(AggregateResult each: alloctions){
           allocMap.put((Id)each.get('ParentProd__c'),(Decimal)each.get('perc') );
       }
     
       //---- Extra check TD: Check if the alloc percent changed-----//
       for(ProductionAllocation__c eachalloc :Trigger.new){
           Decimal allocTobeAdded = eachalloc.AllocationPercent__c;
           Decimal existingalloc  = allocMap.get(eachalloc.ParentProd__c);
           Decimal currentAlloc   = allocTobeAdded+ existingalloc;
           
           //system.debug('existingalloc'+existingalloc); 
           
           if( existingalloc > 100  && (eachalloc.ParentProd__r.IsActive == true )){
              eachalloc.AllocationPercent__c.addError('Cannot be added');
           }
           
       }
       
   }
}