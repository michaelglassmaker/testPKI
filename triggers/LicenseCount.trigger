trigger LicenseCount on User (After insert,After Update) {
    
if(Trigger.isInsert)
{
   set<Id> useronInsertion = new set<Id>();
    
    for(User u : Trigger.New)
    {
       useronInsertion.add(u.Id);
    }
    
    LicensecountHandler.insertlicenseObj(null,null,null,false,true,useronInsertion);
}
    if(Trigger.isUpdate)
    {
        system.debug('inside update');
        Set<Id> useractivated = new Set<Id>();
        Set<Id> LicenseChanged = new Set<Id>();
        Set<Id> userDeactivated = new Set<Id>();
        
       for(User u : Trigger.New)
       {
  
           if(Trigger.oldMap.get(u.Id).IsActive==false && u.IsActive==true)
           {
               useractivated.add(u.Id);
               system.debug('user added to activated list');
           }
           else if(Trigger.oldMap.get(u.Id).License_type__c != Trigger.newMap.get(u.Id).License_type__c)
           {
               LicenseChanged.add(u.Id);
               system.debug('user added to license change list');
           }
           else if(Trigger.oldMap.get(u.Id).IsActive==true && u.IsActive==false && u.License_type__c=='Salesforce')
           {
               userDeactivated.add(u.Id);
               system.debug('user added to deactivated list');
           }
       }
        
        LicensecountHandler.insertlicenseObj(LicenseChanged,useractivated,userDeactivated,true,false,null);
        
    }
}