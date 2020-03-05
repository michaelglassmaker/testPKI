trigger SMAX_PS_ServiceContractEntitlement on SVMXC__Service_Contract_Services__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    SMAX_PS_Utility.executeHandler(new SMAX_PS_ServiceContractEntTriggerHandler());
}