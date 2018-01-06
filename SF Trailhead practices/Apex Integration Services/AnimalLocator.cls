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
