 global class OppSort implements Comparable{
    global final Opportunity oppty{set;get;}
    private String sortBy;

    public OppSort(Opportunity op,String sortOrder){
       this.oppty =op; 
       this.sortBy = (sortOrder == null)? 'date' : sortOrder;
    }
    
    global Integer compareTo(Object compareTo){
        Integer returnVal =0;
        OppSort obj = (OppSort)compareTo;
        
        if(sortBy=='name'){
            if(oppty.name>obj.oppty.name){
              returnVal =1;  
            }
            else{returnVal =-1;}
        }
        else if(sortBy=='amount'){
             if(oppty.amount>obj.oppty.amount){
              returnVal =1;  
            }
            else{returnVal =-1;}
            
        }
        else if(sortBy=='date'){
            if(oppty.createddate>obj.oppty.createddate){
              returnVal =-1;  
            }
            else{returnVal =1;}
        }
        
        return returnVal;
    }
}


