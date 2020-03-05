trigger SMAX_PS_ProductStock on SVMXC__Product_Stock__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    SMAX_PS_Utility.executeHandler(new SMAX_PS_ProductStockTriggerHandler());
}