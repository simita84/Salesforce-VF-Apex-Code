trigger ChessGameTrigger on Game__c (after insert) {
  
  /**
    *    
    Author : Simi Tresa Antony
    Assumptions : This happens only in INSERT TRIGGER, need more time for other cases
    Todo : Bulk Email handling 
           Move code to service class
    */

    if(Trigger.isInsert && Trigger.isAfter){
         List<Game__c> gameList = Trigger.new; 
         ChessGameTriggerService.updatePlayerWithGame(gameList); 
        } 
  
}