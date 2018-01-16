@isTest
public class TestRestrictContactByName {
    @testSetup
    static public  void  allTestData(){
        Contact aCon = new Contact(lastname='name');
        insert aCon;
    }
     static  testMethod void createContact(){
        Contact UpdateCon = new Contact(lastname='INVALIDNAME');
        String msg ='';
        Boolean sawErr ; 
         try{
            insert UpdateCon; 
         }catch(Exception e){
             sawErr = true;
             msg = e.getMessage();
         }
        system.assert(sawErr);
        system.assert(msg.contains('is not allowed for DML'));
    }
    static  testMethod void updateContact(){
       Contact con = [select id,lastname from Contact where lastname ='name' ];
        con.lastname = 'INVALIDNAME';
        
        String msg ='';
        Boolean sawErr ; 
         try{
            update con; 
         }catch(Exception e){
             sawErr = true;
             msg = e.getMessage();
         }
        system.assert(sawErr);
        system.assert(msg.contains('is not allowed for DML')); 
    }
}