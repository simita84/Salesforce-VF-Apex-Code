/**BATCH APEX + DATABASE.upsert(records,false) - How to get all the failed records ID */

 List<Database.SaveResult> updateResults =  DML.updateAsSystem(scope, false);
  for(Integer i=0;i<updateResults.size();i++){
    if (!updateResults.get(i).isSuccess()){
       // DML operation failed
  Database.Error err = updateResults.get(i).getErrors().get(0);
    String failedDML = err.getMessage();
    scope.get(i);//failed record from the list
    system.debug('Failed ID'+scope.get(i).Id);
    messages.add(new Notify.Message(''+err.getStatusCode()+
            ' on record with ID: '+
              scope.get(i).Id, err.getMessage()));
                 }

            }  
