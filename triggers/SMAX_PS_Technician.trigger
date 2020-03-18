trigger SMAX_PS_Technician on SVMXC__Service_Group_Members__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    SMAX_PS_Utility.executeHandler(new SMAX_PS_TechnicianTriggerHandler());
}