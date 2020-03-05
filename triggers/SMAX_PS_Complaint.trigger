trigger SMAX_PS_Complaint on SMAX_PS_Complaint__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    SMAX_PS_Utility.executeHandler(new SMAX_PS_ComplaintTriggerHandler());
}