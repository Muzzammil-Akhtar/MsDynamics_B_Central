public class Api_CallOut_Class {
    
    public static Datetime getSyncDate(string objName){
    //method to get last sync date from metadata
        Map<string, MsDynamics_Objects__mdt> mapOfConfig = new map<string, MsDynamics_Objects__mdt>();
        mapOfConfig = MsDynamics_Objects__mdt.getAll();
        //system.debug('MapofConfig::'+ mapOfConfig);
        
        datetime syncDate = mapOfConfig.get(objName).Last_Sync_Date__c;
        return syncDate;
    }

    
    public static string urlConcat(string data){
    //method to return org name and id for dynamic url completion for api call
        Map<string, MsDynamics__mdt> mapOfConfig = new map<string, MsDynamics__mdt>();
        mapOfConfig = MsDynamics__mdt.getAll();
        //system.debug('MapofConfig::'+ mapOfConfig);
        
       //check to return org name or id for url for api-call
        if(data == 'id'){
            string orgID = mapOfConfig.get('org_id').Data__c;
        	//system.debug('Base URL org id:: '+ orgID);
        	return orgID;
        }
        Else{
            string orgname = mapOfConfig.get('org_Name').Data__c;
        	//system.debug('Base URL org name:: '+ orgname);
        	return orgname;
        }
	}
    
    
    public static HTTPResponse makeRequest(String epURL, String methName, string requestBody){
        //String baseURL = 'callout:Dynamics_365_BC/v1.0/8dd65afe-0467-41c9-aca7-542d293d0413/api/v2.0/';
		string urlId = Api_CallOut_Class.urlConcat('id');
        String baseURL = 'callout:Dynamics_365_BC/v1.0/'+ urlId +'/api/v2.0/';
        String urlCall =  baseURL + epURL;
        HttpRequest req = new HttpRequest();
        system.debug('api call endpoint :: '+urlcall);
        
        req.setEndpoint(urlCall);
        req.setMethod(methName);
        
        if(methName == 'POST'){
            req.setBody(requestBody);
        }
        
        // Add the basic auth string to the Request Header
        //req.setHeader('Authorization', authorizationHeader);  
        req.setHeader('Content-type', 'application/json');
        req.setHeader('accept', 'application/json');
        req.setTimeout(120000);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        return res;
    }
    
 	/*
    public static void calloutTest(String reqbody, String epCall, String methName, String key1, String key2, String hVal){
        
        string username = 'WASIMAKRAM'; 
        string password = 'ce/4KxleCfh5Ty5y6JwHT6lqfHBplgFxXq/sJaHuXxY=';
        //string username = '{!$Credentails.Username}'; 
        //string password = '{!$Credentails.Password}';
        
        Blob headerValue = Blob.valueOf(username + ':' + password);
        //Base 64 Encode the blob and prepend "Basic "
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        
        String baseURL = 'callout:Dynamics_365_BC/v1.0/8dd65afe-0467-41c9-aca7-542d293d0413/api/v2.0/';
        String urlCall;
		epcall = 'companies';
        HttpRequest req = new HttpRequest();
        urlCall = baseURL + epCall;
        
        req.setEndpoint(urlCall);
        req.setMethod(methName);
        
        // Add the basic auth string to the Request Header
        //req.setHeader('Authorization', authorizationHeader);  

        //key1 = Content-type
        //ket2 = accept
        //hVal = name/type
        req.setHeader('Content-type', 'application/json');
        req.setHeader('accept', 'application/json');
        req.setTimeout(120000);
        //req.setbody(reqbody);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        System.debug(res.getStatusCode());
        System.debug(res.getBody());
        
        //string resp = res.getBody();
        //DynContact dc = DynContact.parse(resp);
        //System.debug(dc);
        
    }
	*/
}