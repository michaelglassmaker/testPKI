/*
 *  Trigger Handler for Product Stock [SVMXC__Product_Stock__c]
 *  2017-09-07      Veerendra Moodbidri       Initial creation, for Product Stock Integration.
 */

public with sharing class SMAX_PS_ProductStockTriggerHandler implements SMAX_PS_Utility.ITriggerHandler {

    public SMAX_PS_ProductStockTriggerHandler() {
    }

    public void afterUpdate()
    {
        List<SVMXC__Product_Stock__c> newPstockList = Trigger.new;
        Map<Id, SVMXC__Product_Stock__c> oldPstockMap = (Map<Id, SVMXC__Product_Stock__c>) Trigger.oldMap;
        SMAX_PS_InventoryManager.afterUpdateComplete(newPstockList, oldPstockMap);
    }

    public void beforeUpdate() {}
    public void beforeInsert() {}
    public void afterInsert() {}
    public void beforeDelete() {}
    public void afterDelete() {}
    public void afterUndelete() {}
}