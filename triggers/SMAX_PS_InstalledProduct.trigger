trigger SMAX_PS_InstalledProduct on SVMXC__Installed_Product__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    SMAX_PS_Utility.executeHandler(new SMAX_PS_InstalledProductTriggerHandler());
}