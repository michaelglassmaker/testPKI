trigger SMAX_PS_InvoiceLine on SVMXC__Proforma_Invoice_Line__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    SMAX_PS_Utility.executeHandler(new SMAX_PS_InvoiceLineTriggerHandler());
}