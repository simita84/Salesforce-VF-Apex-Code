/* 
	Apex Specialist Superbadge : SF Trailhead
	https://trailhead.salesforce.com/en/superbadges/superbadge_apex*/


/*  Automate record creation
	Synchronize Salesforce data with an external system
	Schedule synchronization
	Test automation logic
	Test callout logic
	Test scheduling logic */


//--------Automate record creation - trigger

trigger MaintenanceRequest on Case (before insert,after insert,before update,after update) {
  
  /*----Create a Routine Maintenance request every time a maintenance 
     request of type Repair or Routine Maintenance is updated to Closed----*/ 
  if(Trigger.isUpdate && Trigger.isAfter ){  
      System.debug('No of times inside Trigger.isUpdate && Trigger.isAfter');
      MaintenanceRequestHelper.createRoutineMaintenance(Trigger.new);  
   }
    
}

//-------Automate record creation - trigger- Handler Class

public  class MaintenanceRequestHelper {
    
    public static void createRoutineMaintenance(List<Case> maintenceRequests){
        Date today = system.today();
        List<Case> routineMaintences = new  List<Case>(); 
        //------- Create a Map of Maintnece request and min Work order part maintence due days----//
        Map<id,Integer> mapCaseWP = new Map<id,Integer>(); 
        //------- Aggregate the work parts by maintenance requests to find shortest Maintenance_Cycle__c-----//
        List<AggregateResult> prodMainCycleList = [select Maintenance_Request__c request,
                                                         min(Equipment__r.Maintenance_Cycle__c) cnt 
                                                         from Work_Part__c 
                                                         WHERE Maintenance_Request__c IN :maintenceRequests 
                                                         GROUP BY Maintenance_Request__c]; 
         
         for(AggregateResult ar: prodMainCycleList){
             mapCaseWP.put((Id)ar.get('request'),(Integer)ar.get('cnt')); 
         }      
        //  Inserting a new Maintenance Request of type 'Repair' and
        //  then closing it did not work as expected. The challenge was NOT 
        //  expecting to find a Maintenance Request with the same Vehicle and the Status of 
        //  'New' and of Type 'Routine Maintenance'. However, it did.
                                
         for(Case newCase: maintenceRequests){  
             if( (newCase.status != ((Case)Trigger.oldMap.get(newCase.id)).status) && (newCase.status == 'Closed') ){  
                 //Case currCase = new Case();
                      case oldCaseRec = (Case)Trigger.oldMap.get(newCase.id) ;  
                  Case currCase = oldCaseRec.clone();
                      currCase.status='New';  
                      //currCase.type='Routine Maintenance';  
                      //currCase.Vehicle__c = oldCaseRec.Vehicle__c;
                      currCase.subject='Regular Maintenance Follow Ups';
                      currCase.Date_Reported__c = today; 
                      currCase.Date_Due__c =today.addDays(10); //today.addDays(mapCaseWP.get(newCase.id)); 
                      //currCase.Equipment__c = oldCaseRec.Equipment__c;
                 routineMaintences.add(currCase); 
             }
        }
        system.debug(routineMaintences);
        insert routineMaintences;
        
    }

} 

//Synchronize Salesforce data with an external system 

 public with sharing class WarehouseCalloutService {

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    
    // complete this method to make the callout (using @future) to the
    // REST endpoint and update equipment on hand.
    @future(callout=true)
    public static void runWarehouseEquipmentSync(){
        Set<Id> existingEquips = new Set<Id>();
        List<Product2> allProducts = new List<Product2>();
        Http http = new Http();
        HttpRequest req = new HttpRequest();
                    req.setEndpoint(WAREHOUSE_URL);
                    req.setMethod('GET'); 
         HttpResponse resp = http.send(req); 
         //-------successful reesponse-------//
         if(resp.getStatusCode()==200){
             List<EquipmentResponse> equipmentsList = (List<EquipmentResponse>)System.JSON.deserialize(resp.getBody(), 
                                                    List<EquipmentResponse>.class); 
       
           for(EquipmentResponse equip: equipmentsList){
               allProducts.add(new Product2(Cost__c              =   equip.cost,
                                            Maintenance_Cycle__c =   equip.maintenanceperiod,
                                            Lifespan_Months__c   =   equip.lifespan,
                                            Current_Inventory__c =   equip.quantity,
                                            Replacement_Part__c  =   equip.replacement,
                                            Warehouse_SKU__c     =   equip.sku,
                                            Name                 =   equip.name,
                                            id                   =   equip.id ));
           }
       
           if(allProducts.size()>0){
               upsert allProducts;
           }
       
       /* for(EquipmentResponse equip: equipmentsList){
            existingEquips.add(equip.sku);
        }
        List<Product2>  equipRecs = [SELECT Id,name,Cost__c,Lifespan_Months__c,
                                            Maintenance_Cycle__c,Replacement_Part__c,
                                            Warehouse_SKU__c 
                                    FROM Product2 
                                    WHERE Warehouse_SKU__c in :existingEquips];//ExternalId*/
        
        
        
            system.debug(equipmentsList);  
            /*
            EquipmentResponse:[	cost=5000, 
    						equipId=null, lifespan=120, 
    						maintenanceperiod=365, 
    						name=Generator 1000 kW, 
    						quantity=5, 
    						replacement=false, 
    						sku=100003	
    				]
            */
        
        }
         
    } 

  class EquipmentResponse { 
		public String id;
		public Boolean replacement;
		public Integer quantity;
		public String name;
		public Integer maintenanceperiod;
		public Integer lifespan;
		public Integer cost;
		public String sku; 
 
  }

}

//-----------Schedule synchronization

public class WarehouseSyncSchedule implements Schedulable {
  // implement scheduled code here
  public void execute(SchedulableContext sc){
      WarehouseCalloutService.runWarehouseEquipmentSync();
  }
}

