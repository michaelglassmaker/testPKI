trigger AccountTrigger_PreventDeleteBasedOnRecordType on Account (before delete) {
   List<string> allowedProfiles = new List<String>();
    List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
     String MyProfileName = PROFILE[0].Name;
      Boolean isProfileAllowed = false; 
    Map<Id, RecordType > recType  = new Map<ID, RecordType >([select id,Name from RecordType where (Developername = 'PerkinElmer_Entities' OR Developername = 'PKI_Master') AND sobjecttype = 'Account' AND IsActive = TRUE ]);
    /*for(Prevent_Account_Deletion__c preventDelete : Prevent_Account_Deletion__c.getAll().Values()){
        if(String.valueOf(preventDelete) == MyProfileName ){
            isProfileAllowed = true;
        }
    }*/
    if(MyProfileName == 'System Administrator' ){
            isProfileAllowed = true;
        }
    
    if(!recType.isempty()){
       //  String RecordTypeAid = rectype[0].id;
         if(!isProfileAllowed){
         for(Account acc: trigger.old){
            //if(acc.RecordTypeId == RecordTypeAid){
             if(rectype.containsKey(acc.RecordTypeId)){

                 acc.addError('You are not permitted to delete an account of these record types - "PKI Entity and PKI Master"');
            }
        }
     }
    }
}