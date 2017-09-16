public class Hierarchy { 
  
    public class EmployeeDetails{
        public String empId;
        public String name;
        public String title;
        public String reportsTo;
    }
    
    static public void printHierarchy(){
        Map<String, EmployeeDetails> empMap = new Map<String,EmployeeDetails>(); 
        
         EmployeeDetails emp3 = new EmployeeDetails();
                        emp3.empId = '12345';
                        emp3.name = 'Brenda Plager ';
                        emp3.title = 'Senior Designer';
                        emp3.reportsTo = '1234'; 
        EmployeeDetails emp2 = new EmployeeDetails();
                        emp2.empId = '1234';
                        emp2.name = 'Wesley Thomas';
                        emp2.title = 'VP of Design';
                        emp2.reportsTo = '123';  
        EmployeeDetails emp1 = new EmployeeDetails();
                        emp1.empId = '123';
                        emp1.name = 'Flynn Mackie';
                        emp1.title = 'Senior VP of Engineering';
                        emp1.reportsTo = '123456';
         
        empMap.put(emp1.empId,emp1);
        empMap.put(emp2.empId,emp2);  
        empMap.put(emp3.empId,emp3);   
        
       
        Map<integer,EmployeeDetails> mapEmplHierarchyToPrint = new map<integer,EmployeeDetails>();
        
        // ---------------Find topmost Role---------------
        EmployeeDetails topEmp ;
        Integer idx = 1; //assign 0 to topmost employee
        
        for(String eachEmpid : empMap.keySet()){  
            if(  empMap.get(empMap.get(eachEmpid).reportsTo) == null) {
                topEmp = empMap.get(eachEmpid);
                mapEmplHierarchyToPrint.put(0,topEmp);system.debug('topEmp'+topEmp);
                break;
            }
        }
         
        //---------Now got thru all employees----------
        for(String eachEmpid : empMap.keySet()){  
         if( empMap.get(empMap.get(eachEmpid).reportsTo) != null) { 
             if(topEmp.empId ==  empMap.get(eachEmpid).reportsTo){
                 topEmp = empMap.get(eachEmpid);
                 mapEmplHierarchyToPrint.put(idx++,topEmp);
             } 
          
        }}
         system.debug(mapEmplHierarchyToPrint);
         
         for(integer i=0;i<mapEmplHierarchyToPrint.size();i++){
              system.debug(mapEmplHierarchyToPrint.get(i).name +' : '+ mapEmplHierarchyToPrint.get(i).title);
              system.debug('\\t'); 
         } 
    }
}
  // if(empMap.get(empMap.get(eachEmpid).reportsTo)!=null){
            // system.debug('Emp Id: '+eachEmpid+ ' name: '+empMap.get(eachEmpid).name +
            //                 ' title: '+ empMap.get(eachEmpid).title +
            //                 ' reports to '+  empMap.get(empMap.get(eachEmpid).reportsTo).name ); 
// }