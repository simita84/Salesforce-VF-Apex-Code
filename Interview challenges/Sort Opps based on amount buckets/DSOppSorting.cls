Visualforce PAGE

<apex:page controller="OppStages">
  <apex:pageBlock title="Opportunities  bucketed based on  Amount ">
      <apex:pageblockTable value="{!mapOpps}" var="eachMapOpp" >
               <apex:column headerValue="Bucket">
               {!eachMapOpp}
               </apex:column> 
               <apex:column headerValue="Opportunities">
                   <apex:pageBlockTable value="{!mapOpps[eachMapOpp]}" var='eachOpp'>
                       <apex:column>
                           {!eachOpp.name}
                       </apex:column>
                       <apex:column>
                           {!eachOpp.amount}
                       </apex:column>
                   </apex:pageBlockTable> 
               </apex:column> 
           </apex:pageblockTable> 
  </apex:pageBlock>
</apex:page>

APEX CONTROLLER

public with sharing class OppStages {
    public Map<String,List<Opportunity>> mapOpps {get;set;} 
    
    public OppStages(){
        mapOpps = new Map<String,List<Opportunity>>();
        List<Opportunity>  small = new List<Opportunity>();
        List<Opportunity>  medium = new List<Opportunity>();
        List<Opportunity>  large = new List<Opportunity>();
        List<Opportunity> opps = [select id,name,amount 
                                        from Opportunity  
                                        order by createddate desc 
                                        limit 25 ];
        
        for(Opportunity eachOpp:opps){
            if(eachOpp.amount >= 50000 && eachOpp.amount < 100000){
                  small.add(eachOpp); 
            }else if(eachOpp.amount >= 100000 && eachOpp.amount <150000 ){
                  medium.add(eachOpp); 
            }else if( eachOpp.amount >=150000){
                 large.add(eachOpp); 
            }
         
        } 
         mapOpps.put('Small',small);  
         mapOpps.put('Medium',medium);  
         mapOpps.put('Large',large);  
    }
    
}

