/*
 *  Trigger Handler for Inventory Count Line [SMAX_PS_InventoryCountLine__c]
 *  2017-10-05      Frank VanLoon       Initial creation, for Inventory Count Integration.
 */
public with sharing class SMAX_PS_InventoryCountLineTriggerHandler implements SMAX_PS_Utility.ITriggerHandler {

	public SMAX_PS_InventoryCountLineTriggerHandler() {
	}

	public void beforeInsert()
	{
		List<SMAX_PS_InventoryCountLine__c> lineList = Trigger.new;
		SMAX_PS_InventoryManager.lookupCountLineCost(lineList, null);
	}
	public void afterInsert() {}

	public void beforeUpdate()
	{
		List<SMAX_PS_InventoryCountLine__c> lineList = Trigger.new;
		Map<Id, SMAX_PS_InventoryCountLine__c> oldLineMap = (Map<Id, SMAX_PS_InventoryCountLine__c>) Trigger.oldMap;
		SMAX_PS_InventoryManager.lookupCountLineCost(lineList, oldLineMap);
	}
	public void afterUpdate() {}

	public void beforeDelete() {}
	public void afterDelete() {}
	public void afterUndelete() {}

}