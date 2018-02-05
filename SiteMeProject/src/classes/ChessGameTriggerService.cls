public class ChessGameTriggerService {
    /***
     * Usecases 
     * 6. Upon entering a winner for the game, the system shall calculate and update the Total
        Number of Wins, the Total Number of Losses, and the Total Number of Games Played
        for both the winner and the loser. 
        7..Upon entering a winner for the game, send an email to each player indicating who won
     */
     
     public static void updatePlayerWithGame(List<Game__c> gameList){
         List<String> emailAddresses = new List<String>(); 
        Set<Id> allPlayerIds = new Set<Id>(); 
       for(Game__c eachGame : gameList){
           allPlayerIds.add(eachGame.White_Player__c);
           allPlayerIds.add(eachGame.Black_Player__c);
       }
       Map<id,Player__c> mapPlayers =  new  Map<id,Player__c>([select id,name,Total_Number_of_Games_Played__c,Email__c,
                                                                Total_Number_of_Losses__c,Total_Number_of_Wins__c 
                                        from Player__c 
                                        where id in :allPlayerIds]);
      
        
        Map<id,Player__c> mapPlayersToBeUpdated = new  Map<id,Player__c>();
        
        for(Game__c eachGame : gameList){
            Player__c  whitePlayer = mapPlayers.get(eachGame.White_Player__c);
            Player__c  blackPlayer = mapPlayers.get(eachGame.Black_Player__c);
            String WinnerName     ='';
            if(whitePlayer!=null){
                whitePlayer.Total_Number_of_Games_Played__c  = whitePlayer.Total_Number_of_Games_Played__c == null ? 0 : whitePlayer.Total_Number_of_Games_Played__c+1;
                if(eachGame.Winner__c == whitePlayer.Id ){
                    whitePlayer.Total_Number_of_Wins__c += 1;
                    WinnerName = whitePlayer.name;
                }else{
                    whitePlayer.Total_Number_of_Losses__c += 1;
                }
            } 
            
            if(blackPlayer!=null){
               blackPlayer.Total_Number_of_Games_Played__c = blackPlayer.Total_Number_of_Games_Played__c==null ? 0: blackPlayer.Total_Number_of_Games_Played__c+1; 
               if(eachGame.Winner__c == blackPlayer.Id ){
                    blackPlayer.Total_Number_of_Wins__c +=1;
                    WinnerName = blackPlayer.name;
                }else{
                    blackPlayer.Total_Number_of_Losses__c +=1;
                }
            }
            
            mapPlayersToBeUpdated.put(whitePlayer.id,whitePlayer);
            mapPlayersToBeUpdated.put(blackPlayer.id,blackPlayer);
            //-------Add email addresses-------//
            //---- Cud have used Users in the system and their Ids to cut governor limits--//
            emailAddresses.add(whitePlayer.Email__c);
            emailAddresses.add(blackPlayer.Email__c); 
            
            System.debug('emailAddresses'+emailAddresses);
            
             /**
             * Upon entering a winner for the game, send an email to each player indicating who won
               the game and the results. 
            */
            //------ Need to handle in bulk todo-------
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String subject = 'Results for the '+ eachGame.name ;
            String body    = eachGame.name + ' was an exciting game and the winner is '+ WinnerName;
                 email.setToAddresses(emailAddresses);
                 email.setSubject(subject);
                 email.setPlainTextBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }    
        
       
        update mapPlayersToBeUpdated.values(); 
     }

}