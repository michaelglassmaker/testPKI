trigger SMAX_PS_InvoiceDetail on SVMXC__Proforma_Invoice_Detail__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    SMAX_PS_Utility.executeHandler(new SMAX_PS_InvoiceDetailTriggerHandler());
}