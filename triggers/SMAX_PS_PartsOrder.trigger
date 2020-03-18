trigger SMAX_PS_PartsOrder on SVMXC__RMA_Shipment_Order__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    SMAX_PS_Utility.executeHandler(new SMAX_PS_PartsOrderTriggerHandler());
}