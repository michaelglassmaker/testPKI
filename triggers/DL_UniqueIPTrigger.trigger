trigger DL_UniqueIPTrigger on Demo_Log__c (before insert, before update) {
        
    DL_UniqueSYSTEMIP dl_obj = new DL_UniqueSYSTEMIP();
    if(Trigger.isInsert)
    {
        dl_obj.uniqueIP(Trigger.new, null);
    }
    if(trigger.isUpdate)
    {
        dl_obj.uniqueIP(Trigger.new, Trigger.oldMap);
    }
    
}