public class AnimalLocator { 
    public static String getAnimalNameById(Integer animalId){
        String url ='https://th-apex-http-callout.herokuapp.com/animals/'+animalId+''; 
        String animalName ;
        JSON2Apex result;
        Http http = new Http();
        Map<String,Object> animalResult = new  Map<String,Object>();
        HttpRequest req = new HttpRequest();
            req.setEndpoint(url);
            req.setHeader('Content-Type', 'application/json');
            req.setMethod('GET');  
        HttpResponse resp = http.send(req);
        if(resp.getStatusCode() == 200){
          result = (JSON2Apex) Json.deserialize(resp.getBody(), JSON2Apex.class) ; 
          animalName = result.animal.name;
          system.debug(animalName); 
          //Animal:[eats=chicken food, id=1, name=chicken, says=cluck cluck]
        } 
        return animalName;
    }
    
    public class JSON2Apex {
		public Animal animal;
	}

	public class Animal {
		public Integer id;
		public String name;
		public String eats;
		public String says;
	} 
}

/*
    https://th-apex-http-callout.herokuapp.com/animals
    {
        "animals": [
            "majestic badger",
            "fluffy bunny",
            "scary bear",
            "chicken"
        ]
    }
     https://th-apex-http-callout.herokuapp.com/animals/1
    {
        "animal": {
            "id": 1,
            "name": "chicken",
            "eats": "chicken food",
            "says": "cluck cluck"
        }
    }
*/


@isTest
global class AnimalLocatorMock  implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{ "animal": {"id": 1, "name": "chicken", "eats": "chicken food", "says": "cluck cluck" }} ');
        response.setStatusCode(200);
        return response; 
    }
}

@IsTest
public class AnimalLocatorTest {
      @isTest
     public static void checkResult(){
         // Set mock callout class 
    	Test.setMock(HttpCalloutMock.class, new AnimalHttpCalloutMock());    
        //HttpResponse response = AnimalLocator.getAnimalNameById(1);
        String animalName = AnimalLocator.getAnimalNameById(1);
         // Verify that the response received contains fake values
        /*String contentType = response.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = response.getBody();
        System.debug(response.getBody());
        String expectedValue = '{"animal": {"id": 1, "name": "chicken", "eats": "chicken food", "says": "cluck cluck" }}';
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, response.getStatusCode());*/
        System.assertEquals(animalName,'chicken'); 
         
    }
     
}





