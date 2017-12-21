// Tested with SF Developer Workbench
// /services/apexrest/Case/V1/5001a000001Ev9uAAC
@RestResource(urlMapping='/Case/V1/*')
global class ApexRestServiceTest {
    @httpGet
    global static CaseResponse getCaseById(){
        RestRequest req = RestContext.request;
        CaseResponse currentCase = new CaseResponse();
        String caseId = req.requestURI.substring(
          						req.requestURI.lastIndexOf('/')+1);
        List<case> cases = [SELECT CaseNumber,Subject,Status,
                             		Origin,Priority 
                             		FROM Case 
                             		WHERE id =:caseId];
        if(cases.size()>0){
          currentCase.currCase  = cases[0];
            currentCase.status  =  'Success';
            currentCase.error   = null;
        } 
        return currentCase;
    } 
    //--- Wrapper to replace raw apex response--//
    global Class CaseResponse {
        Case currCase;
        String status;
        List<String> error; 
    }
}