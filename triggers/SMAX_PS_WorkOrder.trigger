trigger SMAX_PS_WorkOrder on SVMXC__Service_Order__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    SMAX_PS_Utility.executeHandler(new SMAX_PS_WorkOrderTriggerHandler());
}