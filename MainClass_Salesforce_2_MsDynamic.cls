public class MainClass_Salesforce_2_MsDynamic{
       		// push sf accounts to dyn customers 
	public static void push_Accounts(){
        HTTPResponse res = new HTTPResponse();
      		//Query to get accounts that dont have dyn id populated or if record last modified date greater than lastSyncDate
        Datetime LastSyncDate = Api_CallOut_Class.getSyncDate('Customers_Export');
        list<account> lstAccs = [select id, Name, Phone, Website from account where 
                                 		DynId__c = null or LastModifiedDate >: LastSyncDate limit 20];
        
        datetime crntSyncDate = system.Datetime.now();
        
        if(Test.isRunningTest()){
            for(integer i=0; i<=10; i++){
                Account accTest = new Account();
                accTest.Name = 'Test Account' + i;
                accTest.phone = '123456' + i;
                accTest.website = 'www.test'+ i+'.com';
                lstAccs.add(accTest);
            }
        }
        
        for(Account acc : lstAccs){
            // call constructor for creating json to post in ms-dyn
            // public Value(Acc-number, Acc-name, Address-1, Address-2, City, State, Country, Postal code, Phone, Website)
            Customers.Value c1 = new Customers.Value(null, acc.Name, '', '', '', '', '', '', acc.Phone, acc.Website);
            String reqbody = JSON.serialize(c1, true);
            system.debug(reqbody);
            
           		//Call HTTP POST 
            String epurl = 'customers?company='+ Api_CallOut_Class.urlConcat('name');
            
            if(Test.isRunningTest()){
                Test.setMock(HTTPCalloutMock.class, new MockCallOut());
				res = Api_CallOut_Class.makeRequest(epurl,'POST', reqbody);
            }
            else{
				res = Api_CallOut_Class.makeRequest(epurl,'POST', reqbody);
			}
            
            System.debug(res.getStatusCode());
            System.debug(res.getBody());
            
           		//Check if successful to populate Dyn_Id
            if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
                string respBody = res.getBody();
                Customers.Value cust = (Customers.Value)Json.deserialize(respBody, Customers.Value.class);
                string newId = cust.Id;
                //system.debug(newId);
                acc.DynId__c = newId;
            } 
            else {
                System.debug('THE REQUEST RESULTED IN AN ERROR!!');
            }
        } 
        
        
        if(lstAccs.size() > 0){
            try{
                update lstAccs; 
            }
            catch(exception e){
                system.debug('error:: ' + e.getMessage());
            }
        	system.debug('Accounts are exported successfully and dynamics id is populated');            
            
            	//insert sync time into custom metadata
            Upsert_cstMDT.upsertMetaData('Customers_Export', crntSyncDate);
        }
        else{
			system.debug('There are no accounts to export where dynamics id is not populated or modified date is greater than sync date');
        }
    }
    
      		// update dyn customers into sf
    public static void get_Accounts(){
		string respbody = '';
        HTTPResponse res = new HTTPResponse();
        
        //configure the filter criteria for the records retrieve via api call. get sync date from cstMDT
        string LastSyncDate =''+ Api_CallOut_Class.getSyncDate('Customers_Imported');
        //System.debug('sync date :: ' + LastSyncDate);
        //date format needs to be in yyy-mm-ddThh:mm:ssZ
        LastSyncDate = LastSyncDate.substring(0,10)+'T'+LastSyncDate.substring(11,19)+'Z';
        //set filter criteria in url format 
        string filtercriteria = '&$filter=%20lastModifiedDateTime%20ge%20'+LastSyncDate;
        //system.debug('filtecriteria syntax ::'+filtercriteria);
        
        //configure and call api request method
        String epurl = 'customers?company='+ Api_CallOut_Class.urlConcat('name') + filtercriteria;
        res = Api_CallOut_Class.makeRequest(epurl,'GET', null);
        
        System.debug(res.getStatusCode());
        system.debug('Response Body of Account :: ' + respbody);
        
        if(Test.isRunningTest()){
            res.setStatusCode(200);
         	res.setBody('{\"@odata.context\":\"https://api.businesscentral.dynamics.com/v2.0/862c2ab7-4751-4c34-bc37-13deffb5515d/Sandbox1/api/v2.0/$metadata#customers\",\"value\":[{\"@odata.etag\":\"W/\\\"JzQ0O2RiNzZJbHFDVDFpTnlVN2R6NVhCMjk3Z0lzdDlqZlRsZEluek1nMFgvQ2c9MTswMDsn\\\"\",\"id\":\"2321a77b-a6cd-eb11-9f0a-000d3ae8d14e\",\"number\":\"10002\",\"displayName\":\"Muzzammil & Sons\",\"type\":\"Company\",\"addressLine1\":\"\",\"addressLine2\":\"\",\"city\":\"\",\"state\":\"\",\"country\":\"US\",\"postalCode\":\"\",\"phoneNumber\":\"\",\"email\":\"\",\"website\":\"\",\"taxLiable\":true,\"taxAreaId\":\"00000000-0000-0000-0000-000000000000\",\"taxAreaDisplayName\":\"\",\"taxRegistrationNumber\":\"\",\"currencyId\":\"00000000-0000-0000-0000-000000000000\",\"currencyCode\":\"CAD\",\"paymentTermsId\":\"1f222249-13a8-eb11-bb60-000d3a2b96dd\",\"shipmentMethodId\":\"00000000-0000-0000-0000-000000000000\",\"paymentMethodId\":\"c2232249-13a8-eb11-bb60-000d3a2b96dd\",\"blocked\":\"_x0020_\",\"lastModifiedDateTime\":\"2021-06-15T06:54:10.567Z\"},{\"@odata.etag\":\"W/\\\"JzQ0O0dMd3hmNjRiNEZESFcxQkRVTEFabFNmMHlpV0FDOHZEcVI4K0dLeFYzaE09MTswMDsn\\\"\",\"id\":\"bff25d07-36c8-eb11-9f0a-000d3ae8dd48\",\"number\":\"C00010\",\"displayName\":\"Test customer 1\",\"type\":\"Company\",\"addressLine1\":\"\",\"addressLine2\":\"\",\"city\":\"Toronto\",\"state\":\"\",\"country\":\"CA\",\"postalCode\":\"\",\"phoneNumber\":\"\",\"email\":\"\",\"website\":\"\",\"taxLiable\":true,\"taxAreaId\":\"00000000-0000-0000-0000-000000000000\",\"taxAreaDisplayName\":\"\",\"taxRegistrationNumber\":\"\",\"currencyId\":\"00000000-0000-0000-0000-000000000000\",\"currencyCode\":\"CAD\",\"paymentTermsId\":\"18222249-13a8-eb11-bb60-000d3a2b96dd\",\"shipmentMethodId\":\"00000000-0000-0000-0000-000000000000\",\"paymentMethodId\":\"be232249-13a8-eb11-bb60-000d3a2b96dd\",\"blocked\":\"_x0020_\",\"lastModifiedDateTime\":\"2021-06-08T11:17:17.63Z\"},{\"@odata.etag\":\"W/\\\"JzQ0O0dMd3hmNjRiNEZESFcxQkRVTEFabFNmMHlpV0FDOHZEcVI4K0dLeFYzaE09MTswMDsn\\\"\",\"id\":\"\",\"number\":\"C00010\",\"displayName\":\"Test customer 320\",\"type\":\"Company\",\"addressLine1\":\"\",\"addressLine2\":\"\",\"city\":\"Toronto\",\"state\":\"\",\"country\":\"CA\",\"postalCode\":\"\",\"phoneNumber\":\"\",\"email\":\"\",\"website\":\"\",\"taxLiable\":true,\"taxAreaId\":\"00000000-0000-0000-0000-000000000000\",\"taxAreaDisplayName\":\"\",\"taxRegistrationNumber\":\"\",\"currencyId\":\"00000000-0000-0000-0000-000000000000\",\"currencyCode\":\"CAD\",\"paymentTermsId\":\"18222249-13a8-eb11-bb60-000d3a2b96dd\",\"shipmentMethodId\":\"00000000-0000-0000-0000-000000000000\",\"paymentMethodId\":\"be232249-13a8-eb11-bb60-000d3a2b96dd\",\"blocked\":\"_x0020_\",\"lastModifiedDateTime\":\"2021-06-08T11:17:17.63Z\"},{\"@odata.etag\":\"W/\\\"JzQ0O3J3UWhBb2c3THdHOVo0dHhVTVZxK1U4ekdETjNwUUxQT1B2MkFkN3NZa0k9MTswMDsn\\\"\",\"id\":\"81ca6e06-38c8-eb11-9f0a-000d3ae8dd48\",\"number\":\"10000\",\"displayName\":\"Adatum Corporation\",\"type\":\"Company\",\"addressLine1\":\"192 Market Square\",\"addressLine2\":\"\",\"city\":\"Atlanta\",\"state\":\"GA\",\"country\":\"US\",\"postalCode\":\"31772\",\"phoneNumber\":\"\",\"email\":\"robert.townes@contoso.com\",\"website\":\"\",\"taxLiable\":true,\"taxAreaId\":\"00000000-0000-0000-0000-000000000000\",\"taxAreaDisplayName\":\"\",\"taxRegistrationNumber\":\"\",\"currencyId\":\"00000000-0000-0000-0000-000000000000\",\"currencyCode\":\"CAD\",\"paymentTermsId\":\"1f222249-13a8-eb11-bb60-000d3a2b96dd\",\"shipmentMethodId\":\"00000000-0000-0000-0000-000000000000\",\"paymentMethodId\":\"c2232249-13a8-eb11-bb60-000d3a2b96dd\",\"blocked\":\"_x0020_\",\"lastModifiedDateTime\":\"2021-06-08T09:00:52.937Z\"},{\"@odata.etag\":\"W/\\\"JzQ0O0ZrMzIzQ0FhZ1llN1MwN1licEphQ1JqWHR4RG9OTmtja1FRR0tyKzQ4TjA9MTswMDsn\\\"\",\"id\":\"e8b22bfe-38c8-eb11-9f0a-000d3ae8dd48\",\"number\":\"10001\",\"displayName\":\"Test Customer 2\",\"type\":\"Company\",\"addressLine1\":\"\",\"addressLine2\":\"\",\"city\":\"\",\"state\":\"\",\"country\":\"US\",\"postalCode\":\"\",\"phoneNumber\":\"\",\"email\":\"\",\"website\":\"\",\"taxLiable\":true,\"taxAreaId\":\"00000000-0000-0000-0000-000000000000\",\"taxAreaDisplayName\":\"\",\"taxRegistrationNumber\":\"\",\"currencyId\":\"00000000-0000-0000-0000-000000000000\",\"currencyCode\":\"CAD\",\"paymentTermsId\":\"1f222249-13a8-eb11-bb60-000d3a2b96dd\",\"shipmentMethodId\":\"00000000-0000-0000-0000-000000000000\",\"paymentMethodId\":\"c2232249-13a8-eb11-bb60-000d3a2b96dd\",\"blocked\":\"_x0020_\",\"lastModifiedDateTime\":\"2021-06-08T09:07:48.363Z\"}]}');
        }

		respbody = res.getbody();        
        list<Account> accList = new list<Account>();
			//check response status to proceed or terminate with error
        if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
				//parse dyn item list into sf item class as a list
            Customers dynCust = (Customers)Json.deserialize(respbody, Customers.class);
            system.debug(dynCust.value);
				//store date-time at start of sync
            datetime crntSyncDate = System.Datetime.now();
            
				//run loop iterating each customer in list to create list for upserting into sf
            for(Customers.Value cst : dynCust.value){
                system.debug(cst);
                	// map values from deserialized json to account instance
                Account acc = new Account();
                acc.Name = cst.displayName;
                acc.AccountNumber = cst.number_Z;
                acc.BillingStreet = cst.addressLine1;
                acc.BillingCity = cst.city;
                acc.BillingState = cst.state;
                acc.BillingCountry = cst.country;
                acc.BillingPostalCode = cst.postalCode;
                acc.Phone = cst.phoneNumber;
                acc.Website = cst.website;
                acc.DynId__c = cst.id;
					// insert account instance with mapped values in list for dml
                accList.add(acc);
            }
            system.debug(accList);
				//upsert items as products in salesforce
            try{
                upsert accList DynId__c;
                system.debug('accounts successfully imported');  
                Upsert_cstMDT.upsertMetaData('Customers_Imported', crntSyncDate);
            }
            catch(Exception e){
                system.debug('Could Not Insert Accounts. Error::' + e.getMessage());
            }
        }
        else {
            System.debug('THE REQUEST RESULTED IN AN ERROR!!');
        }
    }
    
       		// get dyn items into sf
    public static void get_Products(){
       	HTTPResponse res = new HTTPResponse();
        	//configure the filter criteria for the records retrieve via api call
        string LastSyncDate =''+ Api_CallOut_Class.getSyncDate('Items_Imported');
		System.debug('sync date :: ' + LastSyncDate);
		LastSyncDate = LastSyncDate.substring(0,10)+'T'+LastSyncDate.substring(11,19)+'Z';
        
        string filtercriteria = '&$filter=%20lastModifiedDateTime%20ge%20'+LastSyncDate;
		system.debug('filtecriteria syntax ::'+filtercriteria);
         
       		//configure request
        //HttpResponse res = Api_CallOut_Class.makeRequest('items?company=CRONUS%20Canada%2C%20Inc.', 'GET', null);
        String epUrl = 'items?company='+ Api_CallOut_Class.urlConcat('name') + Filtercriteria;
        
        try{
            res = Api_CallOut_Class.makeRequest(epUrl, 'GET', null);
        }
        catch(Exception e){
            system.debug('Error With Api Call Out :: '+e);
        }
        
        list<Product2> prodlist = new list<Product2>();
        
        if(Test.isRunningTest()){
            res.setbody('{\"@odata.context\":\"https://api.businesscentral.dynamics.com/v2.0/862c2ab7-4751-4c34-bc37-13deffb5515d/Sandbox1/api/v2.0/$metadata#items\",\"value\":[{\"@odata.etag\":\"W/\\\"JzQ0O1FRWWlzSk83ZDlTVDd1KzVodEFMZEQvTEVMTllTUU45YXljRm00aVlWUVU9MTswMDsn\\\"\",\"id\":\"b1f83a78-3ac8-eb11-9f0a-000d3ae8dd48\",\"number\":\"1001\",\"displayName\":\"Poles\",\"type\":\"Inventory\",\"itemCategoryId\":\"00000000-0000-0000-0000-000000000000\",\"itemCategoryCode\":\"\",\"blocked\":false,\"gtin\":\"\",\"inventory\":0,\"unitPrice\":0,\"priceIncludesTax\":false,\"unitCost\":0,\"taxGroupId\":\"2a242249-13a8-eb11-bb60-000d3a2b96dd\",\"taxGroupCode\":\"TAXABLE\",\"baseUnitOfMeasureId\":\"a9232249-13a8-eb11-bb60-000d3a2b96dd\",\"baseUnitOfMeasureCode\":\"PCS\",\"lastModifiedDateTime\":\"2021-06-08T09:19:38.29Z\"},{\"@odata.etag\":\"W/\\\"JzQ0OytMcUo3UVAzOWNMM2NVMGQrbFdKZjhUZWwrdnEwN3JpMEdOdkpqbDdOM1k9MTswMDsn\\\"\",\"id\":\"eb616ea7-3ac8-eb11-9f0a-000d3ae8dd48\",\"number\":\"1002\",\"displayName\":\"Benches\",\"type\":\"Inventory\",\"itemCategoryId\":\"00000000-0000-0000-0000-000000000000\",\"itemCategoryCode\":\"\",\"blocked\":false,\"gtin\":\"\",\"inventory\":0,\"unitPrice\":0,\"priceIncludesTax\":false,\"unitCost\":0,\"taxGroupId\":\"2a242249-13a8-eb11-bb60-000d3a2b96dd\",\"taxGroupCode\":\"TAXABLE\",\"baseUnitOfMeasureId\":\"a9232249-13a8-eb11-bb60-000d3a2b96dd\",\"baseUnitOfMeasureCode\":\"PCS\",\"lastModifiedDateTime\":\"2021-06-08T09:19:49.333Z\"},{\"@odata.etag\":\"W/\\\"JzQ0OytMcUo3UVAzOWNMM2NVMGQrbFdKZjhUZWwrdnEwN3JpMEdOdkpqbDdOM1k9MTswMDsn\\\"\",\"id\":\"\",\"number\":\"100200320\",\"displayName\":\"Benches\",\"type\":\"Inventory\",\"itemCategoryId\":\"00000000-0000-0000-0000-000000000000\",\"itemCategoryCode\":\"\",\"blocked\":false,\"gtin\":\"\",\"inventory\":0,\"unitPrice\":0,\"priceIncludesTax\":false,\"unitCost\":0,\"taxGroupId\":\"2a242249-13a8-eb11-bb60-000d3a2b96dd\",\"taxGroupCode\":\"TAXABLE\",\"baseUnitOfMeasureId\":\"a9232249-13a8-eb11-bb60-000d3a2b96dd\",\"baseUnitOfMeasureCode\":\"PCS\",\"lastModifiedDateTime\":\"2021-06-08T09:19:49.333Z\"},{\"@odata.etag\":\"W/\\\"JzQ0O0lTazYxVXFDdW80dkRodDNmNjg3N0xXQVZYNk8yQU1nNlN4cS9NT2QyV0k9MTswMDsn\\\"\",\"id\":\"f1616ea7-3ac8-eb11-9f0a-000d3ae8dd48\",\"number\":\"1003\",\"displayName\":\"Lights\",\"type\":\"Inventory\",\"itemCategoryId\":\"00000000-0000-0000-0000-000000000000\",\"itemCategoryCode\":\"\",\"blocked\":false,\"gtin\":\"\",\"inventory\":0,\"unitPrice\":0,\"priceIncludesTax\":false,\"unitCost\":0,\"taxGroupId\":\"2a242249-13a8-eb11-bb60-000d3a2b96dd\",\"taxGroupCode\":\"TAXABLE\",\"baseUnitOfMeasureId\":\"a9232249-13a8-eb11-bb60-000d3a2b96dd\",\"baseUnitOfMeasureCode\":\"PCS\",\"lastModifiedDateTime\":\"2021-06-08T09:20:11.53Z\"}]}');
        }
        
		string respbody = res.getbody();
        system.debug('Response Body of Items/Products :: ' + respbody);
        System.debug(res.getStatusCode());
        
        if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
           		//parse dyn item list into sf item class as a list
            Items dynItems = (Items)Json.deserialize(respbody, Items.class);
            system.debug(dynItems.value);
        	System.debug(res.getStatusCode());            
            List<PricebookEntry> PBELst = new List<PricebookEntry>();
            
            datetime crntSyncDate = System.Datetime.now();
           		//run loop iterating each item in list to create list for upsert into sf
            for(Items.Value item : dynItems.value){
                	// create instance of product for referencing lookups
                system.debug(item);
                Product2 prd = new Product2();
                prd.Name = item.displayName;
                prd.IsActive = true;
                prd.ProductCode = item.itemCategoryCode;
                prd.Dyn_Unit_Price__c = item.unitPrice;
                prd.DynId__c = item.id;
                	// insert Memo instance with mapped values in list for dml
                prodlist.add(prd);
                //system.debug(item+' '+item.id);
                
               		//configure default pricebook list price
               		//create pricebookentry rec
                PricebookEntry pbe = new pricebookentry();
               		//using system.label.Standard_Pricebook as ref id for 'pricebook2.id'
                pbe.Pricebook2Id = system.label.Standard_Pricebook;
               		//insert product2.id by pulling product2.id using DynId__c
                Product2 itemref = new Product2(DynId__c = Item.id);
                pbe.product2 = itemref;
               		//insert listprice from dynamics
                pbe.Dyn_ItmPb_id__c = item.id + system.label.Standard_Pricebook;
                pbe.UnitPrice = item.unitPrice;
                pbe.IsActive = true;
                
               		//create pbe list for dml
                PBELst.add(pbe);
            }
            //system.debug(prodlist);
            //system.debug(PBELst);
            
           		//upsert items as products in salesforce
            try{
                upsert prodlist DynId__c;
                system.debug('items successfully imported');   
                Upsert_cstMDT.upsertMetaData('Items_Imported', crntSyncDate);
            }
            catch(Exception e){
                system.debug('Could Not Insert Products. Error::' + e.getMessage());
            }
            
           		//upsert Pricebook Entry for each Product imported
            try{
                upsert PBELst Dyn_ItmPb_id__c;
                system.debug('Pricebook Entry successfully added');    
            }catch(Exception e){
                system.debug('Could Not Insert PBE. Error::' + e.getMessage());
            }
        }
        else {
            System.debug('THE REQUEST RESULTED IN AN ERROR!!');
        }
    }
    
           // get dyn items into sf
    public static void insert_Remaining_Products(string prodName,
                                                 string prodDynId, double prodUnitPrice){
        	// create product for DML        
		Product2 prd = new product2();
        prd.Name = prodName;
        prd.Dyn_Unit_Price__c = prodUnitPrice;
        prd.IsActive = true;
        prd.DynId__c = prodDynId;

			// DML on Product
		upsert prd DynId__c;
        
        		//configure default pricebook list price
        	//create pricebookentry rec
        PricebookEntry pbe = new pricebookentry();
        	// use custom label to populate pricebook id
        	// using system.label.Standard_Pricebook as ref id for 'pricebook2.id'
        pbe.Pricebook2Id = system.label.Standard_Pricebook;
        	//insert product2.id by pulling product2.id using DynId__c
        Product2 prdref = new Product2(DynId__c = prd.DynId__c);
        pbe.product2 = prdref;
        	//insert listprice from dynamics
        pbe.Dyn_ItmPb_id__c = prd.id + system.label.Standard_Pricebook;
        pbe.UnitPrice = prodUnitPrice;
        pbe.IsActive = true;
        
        //DML on pbe
        upsert pbe Dyn_ItmPb_id__c;
    }

        	// get dyn SalesOrder into sf
    public static void get_SalesOrders(){ 
        HTTPResponse res = new HTTPResponse();
        
       		//configure the filter criteria for the records retrieve via api call
        string LastSyncDate =''+ Api_CallOut_Class.getSyncDate('SalesOrders_Imported');
		System.debug('sync date :: ' + LastSyncDate);
		LastSyncDate = LastSyncDate.substring(0,10)+'T'+LastSyncDate.substring(11,19)+'Z';
        
        string filtercriteria = '&$filter=%20lastModifiedDateTime%20ge%20'+LastSyncDate;
		system.debug('filtecriteria syntax ::'+filtercriteria);
         
       		//configure request
        //HttpResponse res = Api_CallOut_Class.makeRequest('salesOrders?company=CRONUS%20Canada%2C%20Inc.','GET', null);
        String epurl = 'salesOrders?company='+ Api_CallOut_Class.urlConcat('name') + Filtercriteria;
        try{
            res = Api_CallOut_Class.makeRequest(epurl,'GET', null);
        }
        catch(Exception e){
            system.debug('Error With Api Call Out :: '+e);
        }
        if(Test.isRunningTest()){ 
            res.setbody('{\"@odata.context\":\"https://api.businesscentral.dynamics.com/v2.0/862c2ab7-4751-4c34-bc37-13deffb5515d/Sandbox1/api/v2.0/$metadata#salesOrders\",\"value\":[{\"@odata.etag\":\"W/\\\"JzQ0O0tOOW93ZnNrb2E3VnlqS2NReDA1OTVUeVBCajdmRlVMTWNJdXo4Zm45UUk9MTswMDsn\\\"\",\"id\":\"13cc0239-3bc8-eb11-9f0a-000d3ae8dd48\",\"number\":\"S-ORD101001\",\"externalDocumentNumber\":\"\",\"orderDate\":\"2021-06-08\",\"postingDate\":\"2021-06-08\",\"customerId\":\"87bd86d2-fbd7-eb11-bb70-000d3a2694d7\",\"customerNumber\":\"C00010\",\"customerName\":\"Test customer 1\",\"billToName\":\"Test customer 1\",\"billToCustomerId\":\"bff25d07-36c8-eb11-9f0a-000d3ae8dd48\",\"billToCustomerNumber\":\"C00010\",\"shipToName\":\"Test customer 1\",\"shipToContact\":\"\",\"sellToAddressLine1\":\"\",\"sellToAddressLine2\":\"\",\"sellToCity\":\"\",\"sellToCountry\":\"\",\"sellToState\":\"\",\"sellToPostCode\":\"\",\"billToAddressLine1\":\"\",\"billToAddressLine2\":\"\",\"billToCity\":\"\",\"billToCountry\":\"\",\"billToState\":\"\",\"billToPostCode\":\"\",\"shipToAddressLine1\":\"\",\"shipToAddressLine2\":\"\",\"shipToCity\":\"\",\"shipToCountry\":\"\",\"shipToState\":\"\",\"shipToPostCode\":\"\",\"currencyId\":\"00000000-0000-0000-0000-000000000000\",\"currencyCode\":\"CAD\",\"pricesIncludeTax\":false,\"paymentTermsId\":\"18222249-13a8-eb11-bb60-000d3a2b96dd\",\"shipmentMethodId\":\"00000000-0000-0000-0000-000000000000\",\"salesperson\":\"\",\"partialShipping\":true,\"requestedDeliveryDate\":\"0001-01-01\",\"discountAmount\":0,\"discountAppliedBeforeTax\":true,\"totalAmountExcludingTax\":750,\"totalTaxAmount\":0,\"totalAmountIncludingTax\":750,\"fullyShipped\":true,\"status\":\"Draft\",\"lastModifiedDateTime\":\"2021-06-08T10:10:46.32Z\",\"phoneNumber\":\"\",\"email\":\"\"}]}');
        }
        
        string respbody = res.getbody();
        system.debug('Response Body of SalesOrders JSON :: ' + respbody);
        
       		//create list of orders for each account to order link
        list<Order> orderList = new list<Order>();
        
       		//handle response body status
        if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
           		//create list of orders from MS dynamics
            SalesOrder dynOrder = (SalesOrder)Json.deserialize(respbody, SalesOrder.class); 
            system.debug('Individual Order Record Coming from List :: ' + dynOrder.value);
            
            datetime crntSyncDate = System.Datetime.now();
            
           		//run loop to create list of orders for dml
            for(SalesOrder.Value sOrder : dynOrder.value){
                //system.debug(sOrder);
                	// create instances of account & order for referencing lookups
                Order sfOrder = new Order();
                Account accRef = new Account(DynId__c = sOrder.customerId);

                	//populate required fields data on sOrder record
                sfOrder.Account = accRef;
                sfOrder.Status = 'Draft';
                	
                	//sOrder.orderDate;
                sfOrder.EffectiveDate = Datetime.now().Date();
	                //id of 'standard' pricebook stored as a custom label  '01s5e0000061LSeAAM';
                sfOrder.Pricebook2Id = system.label.Standard_Pricebook; 
                sfOrder.DynId__c = sorder.id;
                	//add to list to dml
                orderlist.add(sfOrder);
            } 
            List<orderItem> lstitm = new List<orderItem>();

		   		// loop to iterate adding orders record-id (for order-lines) to a list for calling 
		   		// orderlines method
            for(Order SOV : orderlist){
                	//assign SO dynamic id to variable to pass as param in solines function
                string DynSOid = SOV.DynId__c;
               		//assign pricebook id to variable to pass as param in solines function
                string PBId = sov.Pricebook2Id;
               		//call SOLines function with dynID and pbID as params
               		//store order items in list for dml
                list<OrderItem> result = get_SalesOrderLines(dynSOid, PBId);
                System.debug('Result:: ' + result);
                lstitm.addall(result);
				System.debug('lstitm:: ' + lstitm);
	        }
            
           		// use try catch to upsert list of (sales-order) lines or exit throwing dml-error
            //system.debug(orderlist);
            try{
                upsert orderList DynId__c;
                system.debug('Successfully Upserted:: ' + orderList.size() + 'Sales Orders');
                
                if(lstitm.size() > 0){
                    //system.debug(orderLinesList);
                    UPSERT lstitm DynId__c;
                    System.debug('Successfully Upserted OrderLines in salesorders');
				}
            	//Upsert_cstMDT.upsertMetaData('SalesOrders_Imported', crntSyncDate);
            }
            catch(Exception e){
                system.debug('Could Not Create Sales Order. Error::' + e.getMessage());
            }
        }
        else{
            system.debug('There Was An Error With The SALES-ORDER Response Body/ Bad Response');
        }        
    }
    
       		// get dyn SalesOrder lines into sf
    public static list<OrderItem> get_SalesOrderLines(String dynSOid, String PBId){
        HttpResponse res = new HttpResponse();
       		//configure request 
        //string reqString = 'salesOrders(' +DynSOid+ ')/salesOrderLines/?company=CRONUS%20Canada%2C%20Inc.';
        string epUrl = 'salesOrders(' +DynSOid+ ')/salesOrderLines/?company=' + Api_CallOut_Class.urlConcat('name');
        try{
            res = Api_CallOut_Class.makeRequest(epUrl,'GET', null);
        }
        catch(Exception e){
            system.debug('Error With Api Call Out :: '+ e);
        }
        
        if(Test.isRunningTest()){
            res.setbody('{'+'\"@odata.context\":\"https://api.businesscentral.dynamics.com/v1.0/8dd65afe-0467-41c9-aca7-542d293d0413/api/v2.0/$metadata#salesInvoices(d1a278e4-fbd7-eb11-bb70-000d3a2694d7)/salesInvoiceLines\",'+'\"value\":['+'{'+'\"@odata.etag\":\"W/\\\"JzQ0O01SL0R3S3dZbnVCL3BDb09jTk1NSjVXZzhaNjlyL2F6YjZhR3VwbjkxdkE9MTswMDsn\\\"\",'+'\"id\":\"22d91e02-fcd7-eb11-bb70-000d3a2694d7\",'+'\"documentId\":\"d1a278e4-fbd7-eb11-bb70-000d3a2694d7\",'+'\"sequence\":10000,'+'\"itemId\":\"99bd86d2-fbd7-eb11-bb70-000d3a2694d7\",'+'\"accountId\":\"00000000-0000-0000-0000-000000000000\",'+'\"lineType\":\"Item\",'+'\"lineObjectNumber\":\"1960-S\",'+'\"description\":\"ROMEGuestChair,green\",'+'\"unitOfMeasureId\":\"f3bd86d2-fbd7-eb11-bb70-000d3a2694d7\",'+'\"unitOfMeasureCode\":\"PCS\",'+'\"unitPrice\":289.6,'+'\"quantity\":2,'+'\"discountAmount\":0,'+'\"discountPercent\":0,'+'\"discountAppliedBeforeTax\":false,'+'\"amountExcludingTax\":579.2,'+'\"taxCode\":\"TAXABLE\",'+'\"taxPercent\":13,'+'\"totalTaxAmount\":75.30,'+'\"amountIncludingTax\":654.50,'+'\"invoiceDiscountAllocation\":0,'+'\"netAmount\":579.2,'+'\"netTaxAmount\":75.3,'+'\"netAmountIncludingTax\":654.5,'+'\"shipmentDate\":\"2021-06-28\",'+'\"itemVariantId\":\"00000000-0000-0000-0000-000000000000\",'+'\"locationId\":\"00000000-0000-0000-0000-000000000000\"'+'},'+'{'+'\"@odata.etag\":\"W/\\\"JzQ0OzZsQVk4R0Q5NVF6S0pta01xVDR1ZDlKQkdyMkFCL3JLKzFEa3FseEwyc3M9MTswMDsn\\\"\",'+'\"id\":\"23d91e02-fcd7-eb11-bb70-000d3a2694d7\",'+'\"documentId\":\"d1a278e4-fbd7-eb11-bb70-000d3a2694d7\",'+'\"sequence\":20000,'+'\"itemId\":\"a2bd86d2-fbd7-eb11-bb70-000d3a2694d7\",'+'\"accountId\":\"00000000-0000-0000-0000-000000000000\",'+'\"lineType\":\"Item\",'+'\"lineObjectNumber\":\"2000-S\",'+'\"description\":\"SYDNEYSwivelChair,green\",'+'\"unitOfMeasureId\":\"f3bd86d2-fbd7-eb11-bb70-000d3a2694d7\",'+'\"unitOfMeasureCode\":\"PCS\",'+'\"unitPrice\":285.5,'+'\"quantity\":8,'+'\"discountAmount\":0,'+'\"discountPercent\":0,'+'\"discountAppliedBeforeTax\":false,'+'\"amountExcludingTax\":2284,'+'\"taxCode\":\"TAXABLE\",'+'\"taxPercent\":13,'+'\"totalTaxAmount\":296.92,'+'\"amountIncludingTax\":2580.92,'+'\"invoiceDiscountAllocation\":0,'+'\"netAmount\":2284,'+'\"netTaxAmount\":296.92,'+'\"netAmountIncludingTax\":2580.92,'+'\"shipmentDate\":\"2021-06-28\",'+'\"itemVariantId\":\"00000000-0000-0000-0000-000000000000\",'+'\"locationId\":\"00000000-0000-0000-0000-000000000000\"'+'}'+']'+'}');
        }
        
        string respbody = res.getbody();
        system.debug('Response Body of Sales OrderLines :: ' + respbody);
        
       		//create instances of list of items in order and orders
        list<OrderItem> orderLinesList = new list<OrderItem>();
        List<PricebookEntry> pbe = new List<PricebookEntry>();
        
        OrderLines dynOrderLines = (OrderLines)Json.deserialize(respbody, OrderLines.class);
        system.debug('Deserialized OrderLine Item List :: ' + dynOrderLines.value);
        
        datetime crntSyncDate = System.Datetime.now();
        
        	//run loop to create list of orders for dml
        for(OrderLines.Value sOrderLines : dynOrderLines.value){
            	//check if line item is product else skip
            if(sOrderLines.lineType == 'Item'){
                //system.debug(sOrderLines);
    	            // create instance of memo for mapping
	                // and order-line-item order & product for referencing lookups
                OrderItem sfOrderLines = new OrderItem();    
                Order OrderRef = new Order(DynId__c = dynSOid);
                Product2 lItemref = new Product2(DynId__c = sOrderLines.itemId);
                
               		// run soql to get pricebook entries
                pbe = [Select Id from PricebookEntry where Product2.DynId__c =: sOrderLines.itemId and Pricebook2.Id =: PBId];
                
                if(Test.isRunningTest()){
                    PricebookEntry pbeTest = new PricebookEntry(product2id = '01t5e000000Pv5GAAS');
                    pbe.add(pbeTest);
                }
                
                	// map values from json response to instances of sales-order
				sfOrderLines.Order = OrderRef;
                sfOrderLines.Product2 = lItemref;
                sfOrderLines.quantity = sOrderLines.quantity;
                sfOrderLines.UnitPrice = sOrderLines.unitPrice;
                sfOrderLines.PricebookEntryId = pbe[0].id;
                sfOrderLines.DynId__c = sOrderLines.id;
                
                system.debug('OrderLine Item Returned :: ' + sfOrderLines);
               		// insert record in list for dml   
                orderLinesList.add(sfOrderLines);
            }            			
        }
        system.debug('Order Lines Returned ' + orderLinesList);
        return orderLinesList;
    }
    
       		// get dyn SalesInvoice into sf
    public static void get_SalesInvoices(){
        HTTPResponse res = new HTTPResponse();
       		//configure the filter criteria for the records retrieve via api call
        string LastSyncDate =''+ Api_CallOut_Class.getSyncDate('SalesInvoices_Imported');
		//System.debug('sync date :: ' + LastSyncDate);
		LastSyncDate = LastSyncDate.substring(0,10)+'T'+LastSyncDate.substring(11,19)+'Z';
        
        string filtercriteria = '&$filter=%20lastModifiedDateTime%20ge%20'+LastSyncDate;
		//system.debug('filtecriteria syntax ::'+filtercriteria);
         
        	//configure request
        //HttpResponse res = Api_CallOut_Class.makeRequest('salesOrders?company=CRONUS%20Canada%2C%20Inc.','GET', null);
        String epurl = 'salesInvoices?company='+ Api_CallOut_Class.urlConcat('name') + Filtercriteria;
        try{
            res = Api_CallOut_Class.makeRequest(epurl,'GET', null);
        }
        catch(Exception e){
            system.debug('Error With Api Call Out :: '+ e);
        }
        
        if(Test.isRunningTest()){
            res.setbody('{'+'\"@odata.context\": \"https://api.businesscentral.dynamics.com/v1.0/8dd65afe-0467-41c9-aca7-542d293d0413/api/v2.0/$metadata#salesInvoices\",'+'\"value\": ['+'{'+'\"@odata.etag\": \"W/\\\"JzQ0O0hCYVpNZXpQc2dCZTNqZndnSk1ScFFNbXpYOE5MTXFjRHdnMk9RVlVDcXM9MTswMDsn\\\"\",'+'\"id\": \"d1a278e4-fbd7-eb11-bb70-000d3a2694d7\",'+'\"number\": \"PS-INV103198\",'+'\"externalDocumentNumber\": \"\",'+'\"invoiceDate\": \"2021-04-01\",'+'\"postingDate\": \"2021-04-01\",'+'\"dueDate\": \"2021-04-30\",'+'\"customerPurchaseOrderReference\": \"\",'+'\"customerId\": \"87bd86d2-fbd7-eb11-bb70-000d3a2694d7\",'+'\"customerNumber\": \"30000\",'+'\"customerName\": \"School of Fine Art\",'+'\"billToName\": \"School of Fine Art\",'+'\"billToCustomerId\": \"87bd86d2-fbd7-eb11-bb70-000d3a2694d7\",'+'\"billToCustomerNumer\": \"30000\",'+'\"shipToName\": \"School of Fine Art\",'+'\"shipToContact\": \"Meagan Bond\",'+'\"sellToAddressLine1\": \"100 Queen Street, Suite 500\",'+'\"sellToAddressLine2\": \"\",'+'\"sellToCity\": \"Ottawa\",'+'\"sellToCountry\": \"CA\",'+'\"sellToState\": \"ON\",'+'\"sellToPostCode\": \"K1P 1J9\",'+'\"billToAddressLine1\": \"100 Queen Street, Suite 500\",'+'\"billToAddressLine2\": \"\",'+'\"billToCity\": \"Ottawa\",'+'\"billToCountry\": \"CA\",'+'\"billToState\": \"ON\",'+'\"billToPostCode\": \"K1P 1J9\",'+'\"shipToAddressLine1\": \"100 Queen Street, Suite 500\",'+'\"shipToAddressLine2\": \"\",'+'\"shipToCity\": \"Ottawa\",'+'\"shipToCountry\": \"CA\",'+'\"shipToState\": \"ON\",'+'\"shipToPostCode\": \"K1P 1J9\",'+' \"currencyId\": \"00000000-0000-0000-0000-000000000000\",'+'\"currencyCode\": \"CAD\",'+'\"orderId\": \"00000000-0000-0000-0000-000000000000\",'+'\"orderNumber\": \"\",'+'\"paymentTermsId\": \"f1bb86d2-fbd7-eb11-bb70-000d3a2694d7\",'+'\"shipmentMethodId\": \"00000000-0000-0000-0000-000000000000\",'+'\"salesperson\": \"JO\",'+'\"pricesIncludeTax\": false,'+'\"remainingAmount\": 0,'+'\"discountAmount\": 0,'+'\"discountAppliedBeforeTax\": true,'+'\"totalAmountExcludingTax\": 2863.2,'+'\"totalTaxAmount\": 372.22,'+'\"totalAmountIncludingTax\": 3235.42,'+'\"status\": \"Canceled\",'+'\"lastModifiedDateTime\": \"2021-10-11T15:53:26.487Z\",'+'\"phoneNumber\": \"\",'+'\"email\": \"meagan.bond@contoso.com\"'+'},'+'{'+'\"@odata.etag\": \"W/\\\"JzQ0O2KVk1tRENSRWZBNG5XZFdxcUc1Y0xjbzlHY3dBRnQyQTkwckdxKzFlbTg9MTswMDsn\\\"\",'+'\"id\": \"d3a278e4-fbd7-eb11-bb70-000d3a2694d7\",'+'\"number\": \"PS-INV103215\",'+'\"externalDocumentNumber\": \"\",'+'\"invoiceDate\": \"2021-04-04\",'+'\"postingDate\": \"2021-04-04\",'+'\"dueDate\": \"2021-05-04\",'+'\"customerPurchaseOrderReference\": \"OPEN\",'+'\"customerId\": \"85bd86d2-fbd7-eb11-bb70-000d3a2694d7\",'+'\"customerNumber\": \"10000\",'+'\"customerName\": \"Adatum Corporation\",'+'\"billToName\": \"Adatum Corporation\",'+'\"billToCustomerId\": \"85bd86d2-fbd7-eb11-bb70-000d3a2694d7\",'+'\"billToCustomerNumber\": \"10000\",'+'\"shipToName\": \"Adatum Corporation\",'+'\"shipToContact\": \"Robert Townes\",'+'\"sellToAddressLine1\": \"360 Main Street, Suite 1150\",'+'\"sellToAddressLine2\": \"\",'+'\"sellToCity\": \"Winnipeg\",'+'\"sellToCountry\": \"CA\",'+'\"sellToState\": \"MB\",'+'\"sellToPostCode\": \"R3C 3Z3\",'+'\"billToAddressLine1\": \"360 Main Street, Suite 1150\",'+'\"billToAddressLine2\": \"\",'+'\"billToCity\": \"Winnipeg\",'+'\"billToCountry\": \"CA\",'+'\"billToState\": \"MB\",'+'\"billToPostCode\": \"R3C 3Z3\",'+'\"shipToAddressLine1\": \"360 Main Street, Suite 1150\",'+'\"shipToAddressLine2\": \"\",'+'\"shipToCity\": \"Winnipeg\",'+'\"shipToCountry\": \"CA\",'+'\"shipToState\": \"MB\",'+'\"shipToPostCode\": \"R3C 3Z3\",'+'\"currencyId\": \"00000000-0000-0000-0000-000000000000\",'+'\"currencyCode\": \"CAD\",'+'\"orderId\": \"00000000-0000-0000-0000-000000000000\",'+'\"orderNumber\": \"\",'+'\"paymentTermsId\": \"ebbb86d2-fbd7-eb11-bb70-000d3a2694d7\",'+'\"shipmentMethodId\": \"00000000-0000-0000-0000-000000000000\",'+'\"salesperson\": \"JO\",'+'\"pricesIncludeTax\": false,'+'\"remainingAmount\": 0,'+'\"discountAmount\": 0,'+'\"discountAppliedBeforeTax\": true,'+'\"totalAmountExcludingTax\": 14022.1,'+'\"totalTaxAmount\": 1822.88,'+'\"totalAmountIncludingTax\": 15844.98,'+'\"status\": \"Canceled\",'+'\"lastModifiedDateTime\": \"2021-10-11T15:53:07.457Z\",'+'\"phoneNumber\": \"\",'+'\"email\": \"robert.townes@contoso.com\"'+'},'+'{'+'\"@odata.etag\": \"W/\\\"JzQ0O1NZdW9VK09DcmdWcnZJVFpYQ3lkd0RSVWJPc3Vyb0lHR3NEbVhXQ1RGeDA9MTswMDsn\\\"\",'+'\"id\": \"d5a278e4-fbd7-eb11-bb70-000d3a2694d7\",'+'\"number\": \"S-INV102200\",'+'\"externalDocumentNumber\": \"\",'+'\"invoiceDate\": \"2021-05-01\",'+'\"postingDate\": \"2021-05-01\",'+'\"dueDate\": \"2021-06-01\",'+'\"customerPurchaseOrderReference\": \"OPEN\",'+'\"customerId\": \"85bd86d2-fbd7-eb11-bb70-000d3a2694d7\",'+'\"customerNumber\": \"10000\",'+'\"customerName\": \"Adatum Corporation\",'+'\"billToName\": \"Adatum Corporation\",'+'\"billToCustomerId\": \"85bd86d2-fbd7-eb11-bb70-000d3a2694d7\",'+'\"billToCustomerNumber\": \"10000\",'+'\"shipToName\": \"Adatum Corporation\",'+'\"shipToContact\": \"Robert Townes\",'+'\"sellToAddressLine1\": \"360 Main Street, Suite 1150\",'+'\"sellToAddressLine2\": \"\",'+'\"sellToCity\": \"Winnipeg\",'+'\"sellToCountry\": \"CA\",'+'\"sellToState\": \"MB\",'+'\"sellToPostCode\": \"R3C 3Z3\",'+'\"billToAddressLine1\": \"360 Main Street, Suite 1150\",'+'\"billToAddressLine2\": \"\",'+'\"billToCity\": \"Winnipeg\",'+'\"billToCountry\": \"CA\",'+'\"billToState\": \"MB\",'+'\"billToPostCode\": \"R3C 3Z3\",'+'\"shipToAddressLine1\": \"360 Main Street, Suite 1150\",'+'\"shipToAddressLine2\": \"\",'+'\"shipToCity\": \"Winnipeg\",'+'\"shipToCountry\": \"CA\",'+'\"shipToState\": \"MB\",'+'\"shipToPostCode\": \"R3C 3Z3\",'+'\"currencyId\": \"00000000-0000-0000-0000-000000000000\",'+'\"currencyCode\": \"CAD\",'+'\"orderId\": \"00000000-0000-0000-0000-000000000000\",'+'\"orderNumber\": \"\",'+'\"paymentTermsId\": \"ebbb86d2-fbd7-eb11-bb70-000d3a2694d7\",'+'\"shipmentMethodId\": \"00000000-0000-0000-0000-000000000000\",'+'\"salesperson\": \"JO\",'+'\"pricesIncludeTax\": false,'+'\"remainingAmount\": 12505.15,'+'\"discountAmount\": 0,'+'\"discountAppliedBeforeTax\": true,'+'\"totalAmountExcludingTax\": 11066.5,'+'\"totalTaxAmount\": 1438.65,'+'\"totalAmountIncludingTax\": 12505.15,'+'\"status\": \"Draft\",'+'\"lastModifiedDateTime\": \"2021-08-26T13:23:02.823Z\",'+'\"phoneNumber\": \"\",'+'\"email\": \"robert.townes@contoso.com\"'+'},'+'{'+'\"@odata.etag\": \"W/\\\"JzQ0OzllQ3NyV3RxbGRFQlNXNHo2dlp3bWZNOHNFZVJrUnRISHJEd2Fwd0dUeHM9MTswMDsn\\\"\",'+'\"id\": \"d7a278e4-fbd7-eb11-bb70-000d3a2694d7\",'+'\"number\": \"S-INV102201\",'+'\"externalDocumentNumber\": \"\",'+'\"invoiceDate\": \"2021-04-03\",'+'\"postingDate\": \"2021-04-03\",'+'\"dueDate\": \"2021-04-17\",'+'\"customerPurchaseOrderReference\": \"OPEN\",'+'\"customerId\": \"86bd86d2-fbd7-eb11-bb70-000d3a2694d7\",'+'\"customerNumber\": \"20000\",'+'\"customerName\": \"Trey Research\",'+'\"billToName\": \"Trey Research\",'+'\"billToCustomerId\": \"86bd86d2-fbd7-eb11-bb70-000d3a2694d7\",'+'\"billToCustomerNumber\": \"20000\",'+'\"shipToName\": \"Trey Research\",'+'\"shipToContact\": \"Helen Ray\",'+'\"sellToAddressLine1\": \"1950 Meadowvale Blvd.\",'+'\"sellToAddressLine2\": \"\",'+'\"sellToCity\": \"Missisauga\",'+'\"sellToCountry\": \"CA\",'+'\"sellToState\": \"ON\",'+'\"sellToPostCode\": \"L5N 8L9\",'+'\"billToAddressLine1\": \"1950 Meadowvale Blvd.\",'+'\"billToAddressLine2\": \"\",'+'\"billToCity\": \"Missisauga\",'+'\"billToCountry\": \"CA\",'+'\"billToState\": \"ON\",'+'\"billToPostCode\": \"L5N 8L9\",'+'\"shipToAddressLine1\": \"1950 Meadowvale Blvd.\",'+'\"shipToAddressLine2\": \"\",'+'\"shipToCity\": \"Missisauga\",'+'\"shipToCountry\": \"CA\",'+'\"shipToState\": \"ON\",'+'\"shipToPostCode\": \"L5N 8L9\",'+'\"currencyId\": \"00000000-0000-0000-0000-000000000000\",'+'\"currencyCode\": \"CAD\",'+'\"orderId\": \"00000000-0000-0000-0000-000000000000\",'+'\"orderNumber\": \"\",'+'\"paymentTermsId\": \"e9bb86d2-fbd7-eb11-bb70-000d3a2694d7\",'+'\"shipmentMethodId\": \"00000000-0000-0000-0000-000000000000\",'+'\"salesperson\": \"JO\",'+'\"pricesIncludeTax\": false,'+'\"remainingAmount\": 2794.94,'+'\"discountAmount\": 0,'+'\"discountAppliedBeforeTax\": true,'+'\"totalAmountExcludingTax\": 2473.4,'+'\"totalTaxAmount\": 321.54,'+'\"totalAmountIncludingTax\": 2794.94,'+'\"status\": \"Draft\",'+'\"lastModifiedDateTime\": \"2021-08-26T13:23:02.857Z\",'+'\"phoneNumber\": \"\",'+'\"email\": \"helen.ray@contoso.com\"'+'}'+']'+'}');
        }
        
        string respbody = res.getbody();
        system.debug('Response Body of Sales Invoices ::' + respbody);
       		//replacing number with number_z for parsing due to error in parsing which returns null for number_z field
        string newRespBody = respbody.replaceAll('number', 'number_z');
        system.debug('Response Body of Sales Invoices ::' + newRespBody);
        
       		//handle response body status
        if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
           		//create list of orders for each account to order link
            list<Sales_Invoice__c> invoicelist = new list<Sales_Invoice__c>();
                
           		//create list of orders from MS dynamics
            SalesInvoice dynInvoice = (SalesInvoice)Json.deserialize(newRespBody, SalesInvoice.class);
            system.debug('JSON Deserialized::' + dynInvoice.value);
            
            datetime crntSyncDate = System.Datetime.now();
            
           		//run loop to create list of orders for dml
            for(SalesInvoice.Value sInvoice : dynInvoice.value){
                //system.debug(sInvoice);
                    // create instance of invoice for mapping
	                // and account & order for referencing lookups
	            Sales_Invoice__c sfInvoice = new Sales_Invoice__c();
                Account accRef = new Account(DynId__c = sInvoice.customerId);
                Order orderRef = new Order(DynId__c = sInvoice.orderId);
                	// map values from json response to instances of Memo
                sfInvoice.BillingAccount__r = accRef;
                sfInvoice.Name = sInvoice.number_Z;
                //System.debug('number_Z in Mapping:: ' + sInvoice.number_Z);
                sfInvoice.Status__c = 'Draft';
                sfInvoice.InvoiceDate__c = sInvoice.invoiceDate;
                sfInvoice.DueDate__c = sInvoice.dueDate;
                sfInvoice.TotalChargeTaxAmount__c = sInvoice.totalTaxAmount;
                sfInvoice.TotalChargeAmountWithTax__c = sInvoice.totalAmountIncludingTax;
                sfInvoice.DynId__c = sInvoice.id;
                	// insert invoice instance with mapped values in list for dml
                invoicelist.add(sfInvoice);
            }
            List<Sales_Invoice_Line__c> InvItmLst = new List<Sales_Invoice_Line__c>();
            
            
            	// iterate on sales invoice list to get invoice id for respective invoice lines 
            for(Sales_Invoice__c SInvRec : invoicelist){
                	//assign SI dynamic id to variable to pass as param in sInvoicelines function
                string DynSIid = SInvRec.DynId__c;
                	//call SInvLines function with dynID as params
                list<Sales_Invoice_Line__c> result = get_SalesInvoiceLines(DynSIid);
                system.debug('invoice lines result :: ' + result);
                	//store invoice Lines in list for dml
                InvItmLst.addall(result);
            }

            	// use try catch to upsert list of (sales-order) lines or exit throwing dml-error
            	//system.debug(orderlist);
            try{
                System.debug('invoice list :: '+invoicelist);
                upsert invoicelist DynId__c;
                system.debug('Successfully Upserted:: ' + invoicelist.size() + 'Sales Orders');
                
                	// check if order line items are returned
                if(InvItmLst.size() > 0){
                    //system.debug(InvItmLst);
                    UPSERT InvItmLst DynId__c;
                    System.debug('Successfully Upserted OrderLines in salesorders');
				}
            	//Upsert_cstMDT.upsertMetaData('SalesInvoices_Imported', crntSyncDate);
            }
            catch(Exception e){
                system.debug('Could Not Create Sales Invoices. Error :: ' + e.getMessage());
            }
        }
        else{
            system.debug('There Was An Error With The SALES-ORDER Response Body/ Bad Response');
        } 
    }
    
       		// get dyn SalesInvoice Lines into sf
    public static list<Sales_Invoice_Line__c> get_SalesInvoiceLines(String dynSIid){
        HttpResponse res = new HttpResponse();

       		//configure request 
        //string reqString = 'salesInvoices(' +DynSIid+ ')/salesInvoiceLines/?company=CRONUS%20Canada%2C%20Inc.';
        string epUrl = 'salesInvoices(' +DynSIid+ ')/salesInvoiceLines/?company=' + Api_CallOut_Class.urlConcat('name');
        try{
            res = Api_CallOut_Class.makeRequest(epUrl,'GET', null);
        }
        Catch(Exception e){
            system.debug('Error With Api Call Out :: '+ e);
        }
        
        if(Test.isRunningTest()){
            res.setbody('{'+'\"@odata.context\": \"https://api.businesscentral.dynamics.com/v1.0/8dd65afe-0467-41c9-aca7-542d293d0413/api/v2.0/$metadata#salesInvoices(d3a278e4-fbd7-eb11-bb70-000d3a2694d7)/salesInvoiceLines\",'+'\"value\": ['+'{'+'\"@odata.etag\": \"W/\\\"JzQ0O1JPWndLQWhaamljTFJ5azVnM1IwMkY1R2xtTTAvZVcrREJNVjJhMGxmUWc9MTswMDsn\\\"\",'+'\"id\": \"24d91e02-fcd7-eb11-bb70-000d3a2694d7\",'+'\"documentId\": \"d3a278e4-fbd7-eb11-bb70-000d3a2694d7\",'+'\"sequence\": 10000,'+'\"itemId\": \"9cbd86d2-fbd7-eb11-bb70-000d3a2694d7\",'+'\"accountId\": \"00000000-0000-0000-0000-000000000000\",'+'\"lineType\": \"Item\",'+'\"lineObjectNumber\": \"1968-S\",'+'\"description\": \"MEXICO Swivel Chair, black\",'+'\"unitOfMeasureId\": \"f3bd86d2-fbd7-eb11-bb70-000d3a2694d7\",'+'\"unitOfMeasureCode\": \"PCS\",'+'\"unitPrice\": 285.5,'+'\"quantity\": 5,'+'\"discountAmount\": 0,'+'\"discountPercent\": 0,'+'\"discountAppliedBeforeTax\": false,'+'\"amountExcludingTax\": 1427.5,'+'\"taxCode\": \"TAXABLE\",'+'\"taxPercent\": 13,'+'\"totalTaxAmount\": 185.58,'+'\"amountIncludingTax\": 1613.08,'+'\"invoiceDiscountAllocation\": 0,'+'\"netAmount\": 1427.5,'+'\"netTaxAmount\": 185.58,'+'\"netAmountIncludingTax\": 1613.08,'+'\"shipmentDate\": \"2021-06-28\",'+'\"itemVariantId\": \"00000000-0000-0000-0000-000000000000\",'+'\"locationId\": \"00000000-0000-0000-0000-000000000000\"'+'},'+'{'+'\"@odata.etag\": \"W/\\\"JzQ0O25pZ2NaUlVteW9lQjdEWGNSb3oxTk1OdnJkb1Zab1ZnTnF4ZWhrN29ZVWs9MTswMDsn\\\"\",'+'\"id\": \"25d91e02-fcd7-eb11-bb70-000d3a2694d7\",'+'\"documentId\": \"d3a278e4-fbd7-eb11-bb70-000d3a2694d7\",'+'\"sequence\": 20000,'+'\"itemId\": \"a1bd86d2-fbd7-eb11-bb70-000d3a2694d7\",'+'\"accountId\": \"00000000-0000-0000-0000-000000000000\",'+'\"lineType\": \"Item\",'+'\"lineObjectNumber\": \"1996-S\",'+'\"description\": \"ATLANTA Whiteboard, base\",'+'\"unitOfMeasureId\": \"f3bd86d2-fbd7-eb11-bb70-000d3a2694d7\",'+'\"unitOfMeasureCode\": \"PCS\",'+'\"unitPrice\": 2099.1,'+'\"quantity\": 6,'+'\"discountAmount\": 0,'+'\"discountPercent\": 0,'+'\"discountAppliedBeforeTax\": false,'+'\"amountExcludingTax\": 12594.6,'+'\"taxCode\": \"TAXABLE\",'+'\"taxPercent\": 13,'+'\"totalTaxAmount\": 1637.30,'+'\"amountIncludingTax\": 14231.90,'+'\"invoiceDiscountAllocation\": 0,'+'\"netAmount\": 12594.6,'+'\"netTaxAmount\": 1637.3,'+'\"netAmountIncludingTax\": 14231.9,'+'\"shipmentDate\": \"2021-06-28\",'+'\"itemVariantId\": \"00000000-0000-0000-0000-000000000000\",'+'\"locationId\": \"00000000-0000-0000-0000-000000000000\"'+'},'+'{'+'\"@odata.etag\": \"W/\\\"JzQ0OzZ6YlE0elN6NGQzQTkzd3p3UGRGTTk3SmtUZDV6dUU0cTk4UnVENC8wRms9MTswMDsn\\\"\",'+'\"id\": \"26d91e02-fcd7-eb11-bb70-000d3a2694d7\",'+'\"documentId\": \"d3a278e4-fbd7-eb11-bb70-000d3a2694d7\",'+'\"sequence\": 30000,'+'\"itemId\": \"00000000-0000-0000-0000-000000000000\",'+'\"accountId\": \"00000000-0000-0000-0000-000000000000\",'+'\"lineType\": \"Comment\",'+'\"lineObjectNumber\": \"\",'+'\"description\": \"Thank you for ordering\",'+'\"unitOfMeasureId\": \"00000000-0000-0000-0000-000000000000\",'+'\"unitOfMeasureCode\": \"\",'+'\"unitPrice\": 0,'+'\"quantity\": 0,'+'\"discountAmount\": 0,'+'\"discountPercent\": 0,'+'\"discountAppliedBeforeTax\": false,'+'\"amountExcludingTax\": 0,'+'\"taxCode\": \"\",'+'\"taxPercent\": 0,'+'\"totalTaxAmount\": 0,'+'\"amountIncludingTax\": 0,'+'\"invoiceDiscountAllocation\": 0,'+'\"netAmount\": 0,'+'\"netTaxAmount\": 0,'+'\"netAmountIncludingTax\": 0,'+'\"shipmentDate\": \"0001-01-01\",'+'\"itemVariantId\": \"00000000-0000-0000-0000-000000000000\",'+'\"locationId\": \"00000000-0000-0000-0000-000000000000\"'+'}'+']'+'}');
        }
        
        string respbody = res.getbody();
        system.debug('Response Body of Sales InvoiceLines:: ' + respbody);
        
       		//create list of items in order and orders
        list<Sales_Invoice_Line__c> invoiceLinesList = new list<Sales_Invoice_Line__c>();
        List <String> sInvoicesList = new List <String>();
        	// deserialization for parsing
		InvoiceLines dynInvoiceLines = (InvoiceLines)Json.deserialize(respbody, InvoiceLines.class);
        system.debug(dynInvoiceLines);
                
        datetime crntSyncDate = System.Datetime.now();
        
			//run loop to create list of orders for dml        
        for(InvoiceLines.Value sInvoiceLines : dynInvoiceLines.value){
            	// check if line item is item else skip 
            if(sInvoiceLines.lineType == 'Item'){
                system.debug(sInvoiceLines);
                
	                // create instance of invoice lines for mapping
    	            // and product & invoice for referencing lookups
                Sales_Invoice_Line__c sfInvoiceLines = new Sales_Invoice_Line__c();    
                Sales_Invoice__c invoiceRef = new Sales_Invoice__c(DynId__c = dynSIid);
                Product2 invoiceItemRef = new Product2(DynId__c = sInvoiceLines.itemId);
                
                	// map values from json response to instances of Memo
                sfInvoiceLines.Name = invoiceItemRef.Name;
                sfInvoiceLines.Sales_Invoice__r = invoiceRef;
                sfInvoiceLines.Invoice_Item__r = invoiceItemRef;
                sfInvoiceLines.Quantity__c = sInvoiceLines.quantity;
                sfInvoiceLines.Price__c	= sInvoiceLines.unitPrice;
                sfInvoiceLines.DynId__c = sInvoiceLines.id;
                
               		// insert record in list to return for dml   
                invoiceLinesList.add(sfInvoiceLines);
            }            			
        }    
        //system.debug('invoice lines :: '+invoiceLinesList);
        return invoiceLinesList;
    }
    
       //get sales memo from dynamics to salesforce
    public static void get_SalesMemo(){
        HTTPResponse res = new HTTPResponse();
       		//configure the filter criteria for the records retrieve via api call
        string LastSyncDate =''+ Api_CallOut_Class.getSyncDate('SalesCreditMemos_Imported');
		//System.debug('sync date :: ' + LastSyncDate);
		LastSyncDate = LastSyncDate.substring(0,10)+'T'+LastSyncDate.substring(11,19)+'Z';
        
        string filtercriteria = '&$filter=%20lastModifiedDateTime%20ge%20'+LastSyncDate;
		//system.debug('filtecriteria syntax ::'+filtercriteria);
         
        	//configure request
        //HttpResponse res = Api_CallOut_Class.makeRequest('salesCreditMemos?company=CRONUS%20Canada%2C%20Inc.','GET', null);
        String epurl = 'salesCreditMemos?company='+ Api_CallOut_Class.urlConcat('name') + Filtercriteria;
        try{
            res = Api_CallOut_Class.makeRequest(epurl,'GET', null);
        }
        catch(Exception e){
            system.debug('Error With Api Call Out :: '+e);
        }
        
        if(Test.isRunningTest()){
            res.setBody('{'+'\"@odata.context\": \"https://api.businesscentral.dynamics.com/v1.0/8dd65afe-0467-41c9-aca7-542d293d0413/api/v2.0/$metadata#salesCreditMemos\",'+'\"value\": ['+'{'+'\"@odata.etag\": \"W/\\\"JzQ0O2dGamN1dm9mRVZGK2N5R1hsQ0dJNmRHOTNNMEtGU2xvYUE1ZnA2V2JlS3M9MTswMDsn\\\"\",'+'\"id\": \"c74ffd81-0607-ec11-86bc-000d3ae89616\",'+'\"number\": \"S-CR1001\",'+'\"externalDocumentNumber\": \"\",'+'\"creditMemoDate\": \"2021-04-12\",'+'\"postingDate\": \"2021-04-12\",'+'\"dueDate\": \"2021-04-12\",'+'\"customerId\": \"85bd86d2-fbd7-eb11-bb70-000d3a2694d7\",'+'\"customerNumber\": \"10000\",'+'\"customerName\": \"Adatum Corporation\",'+'\"billToName\": \"Adatum Corporation\",'+'\"billToCustomerId\": \"85bd86d2-fbd7-eb11-bb70-000d3a2694d7\",'+'\"billToCustomerNumber\": \"10000\",'+'\"sellToAddressLine1\": \"360 Main Street, Suite 1150\",'+'\"sellToAddressLine2\": \"\",'+'\"sellToCity\": \"Winnipeg\",'+'\"sellToCountry\": \"CA\",'+'\"sellToState\": \"MB\",'+'\"sellToPostCode\": \"R3C 3Z3\",'+'\"billToAddressLine1\": \"360 Main Street, Suite 1150\",'+'\"billToAddressLine2\": \"\",'+'\"billToCity\": \"Winnipeg\",'+'\"billToCountry\": \"CA\",'+'\"billToState\": \"MB\",'+'\"billToPostCode\": \"R3C 3Z3\",'+'\"currencyId\": \"00000000-0000-0000-0000-000000000000\",'+'\"currencyCode\": \"CAD\",'+'\"paymentTermsId\": \"ebbb86d2-fbd7-eb11-bb70-000d3a2694d7\",'+'\"shipmentMethodId\": \"00000000-0000-0000-0000-000000000000\",'+'\"salesperson\": \"JO\",'+'\"pricesIncludeTax\": false,'+'\"discountAmount\": 0,'+'\"discountAppliedBeforeTax\": true,'+'\"totalAmountExcludingTax\": 15034,'+'\"totalTaxAmount\": 1954.42,'+'\"totalAmountIncludingTax\": 16988.42,'+'\"status\": \"Draft\",'+'\"lastModifiedDateTime\": \"2021-08-27T07:17:09.617Z\",'+'\"invoiceId\": \"00000000-0000-0000-0000-000000000000\",'+'\"invoiceNumber\": \"\",'+'\"phoneNumber\": \"\",'+'\"email\": \"robert.townes@contoso.com\",'+'\"customerReturnReasonId\": \"00000000-0000-0000-0000-000000000000\"'+'}'+']'+'}');
        }
        
        string respbody = res.getbody();
        system.debug('Response Body of Sales Memos :: ' + respbody);
       		//replacing number with number_z for parsing due to error in parsing which returns null for number_z field
        string newRespBody = respbody; //.replaceAll('number', 'number_z');
        system.debug('Response Body of Sales Memos :: ' + newRespBody);
        
       		//handle response body status
        if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
            system.debug('Successfully recieved viable response');
           		//create list of orders for each account to order link
            list<Sales_Credit_Memo__c> memolist = new list<Sales_Credit_Memo__c>();
                
           		//create list of orders from MS dynamics
            SalesCreditMemo dynMemo = (SalesCreditMemo)Json.deserialize(newRespBody, SalesCreditMemo.class);
            system.debug('JSON Deserialized::' + dynMemo.value);
            
            datetime crntSyncDate = System.Datetime.now();
            
           		//run loop to create list of orders for dml
            for(SalesCreditMemo.Value sMemo : dynMemo.value){
                system.debug(sMemo);
                // create instance of memo for mapping
                // and account & invoice for referencing lookups
                Sales_Credit_Memo__c sfMemo = new Sales_Credit_Memo__c();
                Account accRef = new Account(DynId__c = sMemo.customerId);
                Sales_Invoice__c invoiceRef = new Sales_Invoice__c(DynId__c = sMemo.invoiceId);
                // map values from json response to instances of Memo
                sfMemo.Account__r = accRef;
                sfMemo.Name = sMemo.number_Z;
                sfMemo.Post_Date__c = sMemo.postingDate;
                sfMemo.Due_Date__c = sMemo.dueDate;
                sfMemo.Total_Tax__c = sMemo.totalTaxAmount;
                sfMemo.Total_Amount_Including_Tax__c = sMemo.totalAmountIncludingTax;
                sfMemo.DynId__c = sMemo.id;
                // insert Memo instance with mapped values in list for dml
                memolist.add(sfMemo);
            }

            	// use try catch to upsert list of sales-memo or exit throwing dml-error
           	try{
                System.debug('Memo list :: '+ memolist);
                upsert memolist DynId__c;

                system.debug('Successfully Upserted:: ' + memolist.size() + 'Sales Memo');
            	Upsert_cstMDT.upsertMetaData('SalesCreditMemos_Imported', crntSyncDate);
            }
            catch(Exception e){
                system.debug('Could Not Create Sales Credit Memos. Error :: ' + e.getMessage());
            }
        }
        else{
            system.debug('There Was An Error With The SALES-CREDIT-MEMO Response Body/ Bad Response');
        } 
    }
    
        // post products from sf to ms dyn
	/*
    public static void sfProdToDynItem(){
      	datetime lastSyncDate = MsDynamicsApi.getSyncDate('Items');
        list<Pricebookentry> lstPrd = [Select UnitPrice, Product2.Id, Dyn_ItmPb_id__c, Product2.Name, Product2.DynId__c from 
										PricebookEntry where Product2.DynId__c = null or lastModifiedDate >: lastSyncDate limit 20];
		//Sytem.debug(lstprd);
        datetime crntSyncDate = system.Datetime.now();
        
        for(Pricebookentry prd : lstPrd){
            	// create constructor to map the product details into item object
            Produst2 product = prd.Product2;
            Items.Value p1 = new Items.Value(prd.Name, ........);
            String reqbody = JSON.serialize(p1, true);
            system.debug(reqbody);
            
            //Call HTTP POST 
            HTTPResponse resp = Api_CallOut_Class.makeRequest('items?company=CRONUS%20Canada%2C%20Inc.','POST', reqbody);
            System.debug(resp.getStatusCode());
            System.debug(resp.getBody());
            
            // print result
            if(resp.getStatusCode() == 200 || resp.getStatusCode() == 201){
                string respBody = resp.getBody();
                Items.Value itm = (Items.Value)Json.deserialize(respBody, Items.Value.class);
                string newId = itm.Id;
                system.debug(newId);
                prd.DynId__c = newId;
            } 
            else {
                System.debug('THE REQUEST RESULTED IN AN ERROR!!');
            }
        }        
        update lstprd; 
        if(lstprd.size() > 0){
			try{
                update lstAccs; 
            }catch(exception e){
                system.debug('error:: ' + e.getMessage());
            }
        	system.debug('accounts are exported successfully and dynamics id is populated');    
            Upsert_cstMDT.upsertMetaData('Items', crntSyncDate);
        }
        else{
			system.debug('there are no accounts to export where dynamics id is not populated');
		}
    }
     */
}