/*
 *  Trigger Handler for Service Contract [SVMXC__Service_Contract__c]
 *  2017-09-01      Veerendra Moodbidri         Initial creation, for Service Contract Integration.
 *  2017-10-11                                  Added call method "updateRenewedFromAndRenewedTo"            
 */

public with sharing class SMAX_PS_ServiceContractTriggerHandler implements SMAX_PS_Utility.ITriggerHandler {

    public SMAX_PS_ServiceContractTriggerHandler() {
    }

    public void afterUpdate() {
        List<SVMXC__Service_Contract__c> newContractList = Trigger.new;
        Map<Id, SVMXC__Service_Contract__c> oldContractMap = (Map<Id, SVMXC__Service_Contract__c>) Trigger.oldMap;
        SMAX_PS_ServiceContractManager.updateIsDeleted(newContractList, oldContractMap);
    }

    public void beforeUpdate() {
        List<SVMXC__Service_Contract__c> newContractList = Trigger.new;
        Map<Id, SVMXC__Service_Contract__c> oldContractMap = (Map<Id, SVMXC__Service_Contract__c>) Trigger.oldMap;
        SMAX_PS_ServiceContractManager.updateIsDeletedByCancelNotes(newContractList, oldContractMap);
        SMAX_PS_ServiceContractManager.updateRenewedFromAndRenewedTo(newContractList, oldContractMap);
    }
    public void beforeInsert() {
        List<SVMXC__Service_Contract__c> newContractList = Trigger.new;
        SMAX_PS_ServiceContractManager.updateIsDeletedByCancelNotes(newContractList, null);
        SMAX_PS_ServiceContractManager.updateRenewedFromAndRenewedTo(newContractList, null);        
    }
    public void afterInsert() {}
    public void beforeDelete() {}
    public void afterDelete() {}
    public void afterUndelete() {}
}