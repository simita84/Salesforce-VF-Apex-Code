@isTest
private class ChessGameTest {

    @testSetUp
    private static void  createTestData(){  
        List<Player__c> players = Test.loadData(Player__c.sObjectType, 'Players');
        
        List<Game__c> games = new List<Game__c>();
        games.add(new Game__c(name='game1',White_Player__c=players[1].id,
                                black_player__c =players[0].id,winner__c=players[0].id));
        games.add(new Game__c(name='game2',White_Player__c=players[1].id,
                                black_player__c =players[0].id,winner__c=players[0].id));
        games.add(new Game__c(name='game3',White_Player__c=players[1].id,
                                black_player__c =players[0].id,winner__c=players[1].id));
        
        insert games;
        
       
        
    }
    
    
   /**
   *  Verify the total games played, total wins and total losses on player record
   **/
	private static testMethod void testGameResults() {
	     //----- Albert --> black  player wins =2 ; Total games 3  
	     ///-----laura --> white player wins =1 ; Total games 3  
	    Test.startTest();  
    	    List<Player__c> players = [select id,name,Total_Number_of_Games_Played__c,
    	                                     Total_Number_of_Losses__c,Total_Number_of_Wins__c,Win_Ratio__c
    	                                     FROM Player__c 
    	                                     where name ='Albert'];
    	    
    	    List<Game__c> games = [select id,white_player__c,black_player__c from Game__c];
    	    System.debug(players);
    	Test.stopTest();
    	
	    
	    System.assertEquals(players[0].Total_Number_of_Games_Played__c,3);
	    System.assertEquals(players[0].Total_Number_of_Wins__c,2);
	    System.assertEquals(players[0].Total_Number_of_Losses__c,1);
	    System.assertEquals(players[0].Win_Ratio__c,66.67);
	    
	    

	}
	 /**
   *  Verify the  Games Statistics page and controller
   **/
	private static testMethod void GameStatisticsPage(){
	  Test.startTest(); 
	       List<Player__c> players = [select id,name,Total_Number_of_Games_Played__c,
    	                                     Total_Number_of_Losses__c,Total_Number_of_Wins__c,Win_Ratio__c
    	                                     FROM Player__c];
          PageReference pageRef = Page.GameStatisticsPage;
          Test.setCurrentPage(pageRef); 
          GameStatisticsExt gamesListPage = new GameStatisticsExt(); 
       Test.stopTest(); 
      system.assert(gamesListPage.mapPlayerGames.size()>0);
	}
	
	private static testMethod void testEmailSent() {
	    //SendGameResults.sendEmailGR(eachGame,emailAddresses,WinnerName);
	}
	
	
	
	
	
	 

}