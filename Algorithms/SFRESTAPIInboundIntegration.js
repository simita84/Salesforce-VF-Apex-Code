/**
 * Created by simiantony on 12/18/17. Sample Salesforce REST API based Inbound Integration
 */
 
'use strict';
import jsforce from 'jsforce'
import SFOrgAuth from './../SFOrgAuth.json'

let sfConn 		= null,
    sfLoginURL  =  SFOrgAuth.loginUrl,
    username 	=  SFOrgAuth.userName,
    password 	=  SFOrgAuth.password
 
//----------Node Server Config. Running on local server--------//
var myserver = http.createServer(function (req, res) {
    res.writeHead(200, {'Content-Type': 'text/html'});
    res.end('Connected !!!!');
});
myserver.listen(8080);
  
sfAuthentication()
	.then((response)=>{
		
		//--- Connection successfull
    	console.log(sfConn.accessToken);
    	console.log(sfConn.instanceUrl);
    
   		 // logged in user property
    	console.log("User ID: " + response.id);
    	console.log("Org ID: "  + response.organizationId);
    
        //----------Query Accounts----------//
    	sfConn.query("SELECT Id, Name  FROM Account", function(err, res) {
       	 if (err) console.log(err);
        	console.log(res.records);
    	});
    	var accounts = [
        	{Name : 'My Account #1'},{Name : 'My Account #2'},
        	{Name : 'My Account #3'},{Name : 'My Account #4'}
    	]
    
 		//----------Create Accounts----------//
    	sfConn.sobject("Account").create( accounts, function(err, results) {
        	if (err || !ret.success) {
				return console.error(err, ret);
            }
        	//console.log("Created record id : " ,ret);
        	results.forEach(function(eachResult){
           		console.log(eachRec.success);
            	console.log(eachRec.id);
            	console.log(eachRec.errors);
        	})

    	});
	})


function sfAuthentication(){
	return new Promise( (resolve, reject) => {
		sfConn = new jsforce.Connection({
    		loginUrl : sfLoginURL
		});
		sfConn.login(username, password, (err, userInfo) => {
            if(err) {
                reject (err)
            }else{
                resolve(userInfo)
            }
        })
	
	})
}







