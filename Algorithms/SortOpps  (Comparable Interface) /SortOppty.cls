public with sharing class SortOppty {
 
    public String sortBy{get;set;}
    private List<Opportunity> opptyList;
   
    //Calling comparable   class
    public List<OppSort> oppty ;
     
    public List<OppSort>  getOppty(){
        return oppty;
    }
    public PageReference sort() {        
        sortMeth(); 
        return null;
    }
    
    public void sortMeth(){       
        oppty = new List<OppSort>();
        for(Opportunity opp: opptyList){
          oppty.add(new OppSort(opp,sortBy) );
      } 
      oppty.sort(); 
    } 
    public SortOppty(){ 
      opptyList = [SELECT id,name,amount,createddate 
                   FROM Opportunity 
                   ORDER BY createddate DESC LIMIT 10];   
      sortMeth();
    }
    }
