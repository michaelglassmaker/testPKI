trigger SMAX_PS_InventoryCountLine on SMAX_PS_InventoryCountLine__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    SMAX_PS_Utility.executeHandler(new SMAX_PS_InventoryCountLineTriggerHandler());
}