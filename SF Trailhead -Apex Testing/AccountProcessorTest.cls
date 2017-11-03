@istest(SeeAllData=true) // to make all records in org avaiable  in tests
public class AccountProcessorTest {
    public  static testMethod  void testContactCount(){
        List<account> accnts = [select id from account limit 10];
        system.debug('accnts'+accnts);
        List<id> accIds = new List<id>();
        for(account acc: accnts){
            accIds.add(acc.id);
        }
        Test.startTest();
         AccountProcessor.countContacts(accIds);
        Test.stopTest();
        List<account> updatedAccounts = [select id from account where id in :accnts];
        system.debug('updatedAccounts'+updatedAccounts); 
        
    }
}