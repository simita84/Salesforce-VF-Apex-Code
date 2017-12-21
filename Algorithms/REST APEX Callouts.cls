/**
 *  Apex REST Callouts from SF to AWS API GATEWAY/ Step functions/ Lambdas
 */
public with sharing class RESTAPEXCallout {

        public static String orgId                        = UserInfo.getOrganizationId();
        public static String userId                       = UserInfo.getUserId();
       
               
        public class CustomException extends Exception {}
        public class JSONToApex {
           public String  errorMessage;
           public String  errorType;
           public List<String> stackTrace;
        }
 
        public with sharing class performCallout  {
            public void execute(){ 
             
             Monitor_Progress__c progressObj = new Monitor_Progress__c(OrgID__c=orgId,
                                                                            UserID__c=userId);
                //----DML Operation before callout-------//
                insert progressObj;
                ID jobID = System.enqueueJob(new QueueableCallouts(progressObj));
                return resp;
            }
        }
        
        public class QueueableCallouts implements Queueable ,Database.AllowsCallouts{
            Monitor_Progress__c progressObj   { get; set; }
            public QueueableCallouts( Monitor_Progress__c  progressObj ) {
                this.progressObj =  progressObj;

            }

            public void execute(QueueableContext context) {
				
				
                HTTPResponse httpRes    ;
                String httpMethod  = 'POST';
                Http http          = new Http();
                
				//--- AWS 	accessKeyId &&  secretKey stored in Custom Settings---//
                 CustomSettConfig__c accessKeyId ;
                 CustomSettConfig__c secretKey ;
                try{
                    accessKeyId = CustomSettConfig__c.getValues('accessKeyId'); 
                    secretKey   = CustomSettConfig__c.getValues('secretKey'); 
                }catch(Exception cannotFindAWSSettings){
                     progressObj.Error_Messsage__c = 'Custom Settings missing for AWS accessId or Secret Key';
                     progressObj.Status__c = 'FAIL';
                }
			   
			   // ------- Signature Version 4 Signing Process implemented in this Class - 	
			   //-------- Taken from https://github.com/bigassforce/aws-sdk------//
               
               Connector connector = new Connector(accessKeyId,secretKey,'apigateway','us-west-2') ; 
            	
                Url awsAPIendpoint ;
                KNDY4__Service_Configuration__c endPointConfig ;
                KNDY4__Configuration__c stateMachineConfig ;
                boolean presign                     = null;
               
                Map<String,List<String>> sdDetails  = new  Map<String,List<String>>();
                Map<String,String>       payloadStr  = new  Map<String,String>();
				Map<String,String> headers     = new Map<String,String>{
                                        				'Content-Type' => 'application/json; 
                                        					charset=utf-8'};
				Map<String,Object>       orgDetails  = new  Map<String,Object>();
                
				//------ Minimum payload------//
                orgDetails.put('orgId' ,orgId);
                orgDetails.put('userId',+userId); 
                orgDetails.put('name',orgId+'-'+progressObj.Id);
                
                //----Serializes orgDetails into JSON content before sending----//
                payloadStr.put('input',JSON.serialize(orgDetails)); 
                
                //----- Fetching Statemachine details in custom settings to and sending in payload --------- 
                try{
                    stateMachineConfig = CustomSettConfig__c.getValues('StateMachine');
                    if(stateMachineConfig!=null){
                         payloadStr.put('stateMachineArn', ''+stateMachineConfig.Value__c);
                    }
                }catch(Exception cannotFindStateMachineSettings){
                     progressObj.Error_Messsage__c = ' State Machine Settings Custom Setting \'StateMachine\' Missing';
                     progressObj.Status__c = 'FAIL'; 
                }
				//-----Fetching APIGateway_URL or the endpoint in custom settings -------------
                try{
                    endPointConfig = CustomSettConfig__c.getValues('APIGateway_URL');
                    awsAPIendpoint = new Url(''+endPointConfig.URL__c); 
                }
                catch(Exception cannotFindSettings){
                     progressObj.Error_Messsage__c = ' AWS APIendpoint Custom Setting \'APIGateway_URL\' Missing';
                     progressObj.Status__c = 'FAIL';
                }

                //--------- If the APIGateway_URL && stateMachineConfig is in  custom settings good to do the callout----------//
                if(endPointConfig!=null && stateMachineConfig!=null){
                     //------Update process execution--------------//
                     progressObj.Sent_on__c = System.now(); 

                    Blob payload = Blob.valueOf(JSON.serialize(payloadStr));// had to serialize again
                    
                    //----- AWS version 4 signing process------//
                    HttpRequest request = connector.signedRequest(httpMethod, awsAPIendpoint,headers, payload, presign); 
                    
                    try{
                      httpRes = http.send(request);
                      JSONToApex respObj = (JSONToApex) System.JSON.deserialize(httpRes.getBody(), JSONToApex.class);
                     

                     if(respObj.errorType!=null && respObj.errorType.contains('Error')){
                          progressObj.Status__c = 'FAIL';
                          progressObj.Error_Messsage__c = respObj.errorMessage;
                     }else{
                          progressObj.Status__c = 'IN PROGRESS';
                     }
 
                    }
                    catch(System.CalloutException callOutExc){ 
                        progressObj.Error_Messsage__c =  callOutExc.getMessage();
                        progressObj.Status__c = 'FAIL';
                    }
                }

                //--------- Update Process Exe Object for job status---------//
                try{
                  update progressObj; 
                }catch(Exception updateException){
                  System.debug(loggingLevel.info,'Updating   progressObj failed '+updateException.getMessage());
                }


        }

    }
}



 //-----------Trial to monitor Cloud watch logs---------//

         /*
          system.debug('httpRes.getBody()'+httpRes.getBody());
           LogsPayloadStr.put('stateMachineArn','arn:aws:states:us-west-2:500403815543:stateMachine:AccountingEngine20170403');
           LogsPayloadStr.put('executionArn', '00D46000000pLAeEAM-a3F46000000ULMrEAO');
          Integer indx =1;
          //-------Send request till all results fetched---
          while (parser.nextToken() != null) {
             if ((parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText()=='executionArn') ) {
                //LogsPayloadStr.put('executionArn',
                //JSON.serialize('arn:aws:states:us-west-2:500403815543:execution:AccountingEngine20170403:3eb72de0-0618-41e3-83c7-e96fa19c93df'));
                 //LogsPayloadStr.put('executionArn'+parser.getText());
                 system.debug('parser'+parser);

                parser.nextToken();
             }
            //LogsPayloadStr.put('maxResults',JSON.serialize(100));
           // LogsPayloadStr.put('nextToken',JSON.serialize(''+parser.nextToken()+''));
            //LogsPayloadStr.put('reverseOrder', JSON.serialize(true));



          indx++;
         }
          blob logsPayload = Blob.valueOf(JSON.serialize(LogsPayloadStr));
            system.debug('LogsPayloadStr'+LogsPayloadStr);

         HttpRequest logRequest = connector.signedRequest(httpMethod, awsAPIendpoint,headers, logsPayload, presign);
          HTTPResponse logResponse = http.send(logRequest);
          system.debug('LOGS'+indx+'--> '+logResponse.getBody());
         */