trigger SMAX_PS_Invoice on SVMXC__Proforma_Invoice__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    SMAX_PS_Utility.executeHandler(new SMAX_PS_InvoiceTriggerHandler());
}