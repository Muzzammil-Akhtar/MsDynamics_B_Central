public class Upsert_cstMDT implements Metadata.DeployCallback{
    @future(callout = true)
    public static void upsertMetaData(String objectName, DateTime syncDate){
    //method to upsert records to store last sync date into custom metadata
        // Intialize the Meta Data which needs to update
        MetaData.CustomMetadata customMDT =  new MetaData.CustomMetaData();
        
        // full name is object name + recordName which needs to upsert
        //mapping standard fields
        customMDT.fullName  = 'MsDynamics_Objects.' + objectName;
        customMDT.Label = objectName;
        
        List<Metadata.CustomMetadataValue> metadatafields = new List<Metadata.CustomMetadataValue>();
        
        //mapping custom fields
        Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
        
        // initialize and populate the custom field
        customField.field = 'Last_Sync_Date__c';
        customField.value = syncDate;
        //insert custom field into list 
        metadatafields.add(customField);
        
        customMDT.values.addAll(metadatafields);
        
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(customMDT);
        
        
        Upsert_cstMDT msDObj = new Upsert_cstMDT();
         // Enqueue custom metadata deployment
        // jobId is the deployment ID
        
        // Enqueue custom metadata deployment
		Id jobId = Test.isRunningTest() ? '0Af5e00000Cwg5g' : Metadata.Operations.enqueueDeployment(mdContainer, msDObj);
        
        //Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
        system.debug('JobID::'+jobId);
    }
    
    
    public static Metadata.CustomMetadataValue createCustomMetadataField(String field,String fieldValue){
        Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
        customField.field = field;
        customField.value = fieldValue;
        return customField;
    }
    
    
    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            System.debug('success: '+ result);
        } else {
            // Deployment was not successful
            System.debug('fail: '+ result);
        }
    }

}