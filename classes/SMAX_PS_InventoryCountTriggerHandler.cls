/*
 *  Trigger Handler for Inventory Count [SMAX_PS_InventoryCount__c]
 *  2017-09-07      Veerendra Moodbidri       Initial creation, for Product Stock Integration.
 */

public with sharing class SMAX_PS_InventoryCountTriggerHandler implements SMAX_PS_Utility.ITriggerHandler {

    public SMAX_PS_InventoryCountTriggerHandler() {
    }

    public void beforeInsert() 
    {
        List<SMAX_PS_InventoryCount__c> invCountList = Trigger.new;

        SMAX_PS_InventoryManager.copyInventoryCountTechs(invCountList);
    }

    public void afterInsert() {}

    public void beforeUpdate() {}

    public void afterUpdate()
    {
        List<SMAX_PS_InventoryCount__c> invCountList = Trigger.new;
        Map<Id, SMAX_PS_InventoryCount__c> oldInvCountMap = (Map<Id, SMAX_PS_InventoryCount__c>) Trigger.oldMap;

        SMAX_PS_InventoryManager.createInventoryCountEvents(invCountList, oldInvCountMap);
    }

    public void beforeDelete() {}
    public void afterDelete() {}
    public void afterUndelete() {}

}