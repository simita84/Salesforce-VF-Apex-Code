/**
*   This is a page controller class to  provide a single view of Players and their stats along with Games and
    their stats.
    Author : Simi Tresa Antony
*/
public  with sharing class GameStatisticsExt  {
    
    public Map<Player__c,List<Game__c>> mapPlayerGames {get;set;}
    
    public GameStatisticsExt(){
      
      mapPlayerGames =  new Map<Player__c,List<Game__c>>();  
       
      List<Player__c> playersLst = [select id,name ,Total_Number_of_Games_Played__c,
                                        Total_Number_of_Losses__c,Total_Number_of_Wins__c,Win_Ratio__c,
                                         (select id,name ,white_player__c,winner__r.name,Date_of_Game__c 
                                                        from Chess_Games1__r ), 
                                         (select id,name , black_player__c,winner__r.name,Date_of_Game__c 
                                                        from Chess_Games2__r )
                                    from Player__c];
                 
      for(Player__c eachPlayer: playersLst){
            
          if(mapPlayerGames.get(eachPlayer)!=null){
             
              if( eachPlayer.Chess_Games1__r.size() > 0 ){
                  mapPlayerGames.get(eachPlayer).add(eachPlayer.Chess_Games1__r) ; 
              }
              
              if( eachPlayer.Chess_Games2__r.size() > 0){
                  mapPlayerGames.get(eachPlayer).add(eachPlayer.Chess_Games2__r) ;
              }
             
          }
          else{
              
              if( eachPlayer.Chess_Games1__r.size() > 0 ){ 
                List<Game__c> games = new List<Game__c>();games.addAll(eachPlayer.Chess_Games1__r);
                mapPlayerGames.put(eachPlayer,games); 
              } 
              if(eachPlayer.Chess_Games2__r.size() > 0 ){ 
                 List<Game__c> games = new List<Game__c>();games.addAll(eachPlayer.Chess_Games2__r);
                 mapPlayerGames.put(eachPlayer,games); 
              }
              
          }
      }      
    }
    

}