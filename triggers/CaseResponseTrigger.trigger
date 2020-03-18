trigger CaseResponseTrigger on Case (before update, after update, before delete, after delete) 
{
    if(Trigger.isUpdate && Trigger.isBefore)
        CaseTriggerHandler.beforeUpdate(Trigger.new);
    
    if(Trigger.isDelete && Trigger.isBefore)
        CaseTriggerHandler.beforeDelete(Trigger.old);
}