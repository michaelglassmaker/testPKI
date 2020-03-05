trigger SMAX_PS_ServiceContract on SVMXC__Service_Contract__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    SMAX_PS_Utility.executeHandler(new SMAX_PS_ServiceContractTriggerHandler());
}