public with sharing class SMAX_PS_PartsOrderTriggerHandler implements SMAX_PS_Utility.ITriggerHandler{
    
    public SMAX_PS_PartsOrderTriggerHandler() {
    }
    
    public void beforeInsert() {
        List<SVMXC__RMA_Shipment_Order__c> newList = Trigger.new;

        SMAX_PS_PartsOrderManager.copyRelatedData(newList);
        SMAX_PS_PartsOrderManager.lookupMasterPartsOrder(newList, null);
        SMAX_PS_PartsOrderManager.lookupLoanerEquipment(newList, null);
        SMAX_PS_PartsOrderManager.trimValues(newList, null);
    }
    public void beforeUpdate() {
        List<SVMXC__RMA_Shipment_Order__c> newList = Trigger.new;
        Map<Id, SVMXC__RMA_Shipment_Order__c> oldMap = (Map<Id, SVMXC__RMA_Shipment_Order__c>) Trigger.oldMap;

        SMAX_PS_PartsOrderManager.copyRelatedData(newList);
        SMAX_PS_PartsOrderManager.lookupMasterPartsOrder(newList, oldMap);
        SMAX_PS_PartsOrderManager.lookupLoanerEquipment(newList, oldMap);
        SMAX_PS_PartsOrderManager.trimValues(newList, oldMap);
        SMAX_PS_PartsOrderManager.poStatusChanges(newList, oldMap);
    }
    public void afterInsert()
    {
        List<SVMXC__RMA_Shipment_Order__c> newList = Trigger.new;
        Map<Id, SVMXC__RMA_Shipment_Order__c> oldMap = (Map<Id, SVMXC__RMA_Shipment_Order__c>) Trigger.oldMap;
        SMAX_PS_PartsOrderManager.createPartsOrderEvents(newList, oldMap);
    }
    public void afterUpdate()
    {
        List<SVMXC__RMA_Shipment_Order__c> newList = Trigger.new;
        Map<Id, SVMXC__RMA_Shipment_Order__c> oldMap = (Map<Id, SVMXC__RMA_Shipment_Order__c>) Trigger.oldMap;
        //SMAX_PS_PartsOrderManager.assignToDepot(newList, oldMap);
        SMAX_PS_PartsOrderManager.createPartsOrderEvents(newList, oldMap);
    }
    public void beforeDelete() {}
    public void afterDelete() {}
    public void afterUndelete() {}   
}