public with sharing class SMAX_PS_StockTransferTriggerHandler implements SMAX_PS_Utility.ITriggerHandler {
	public SMAX_PS_StockTransferTriggerHandler() {
	}

	public void beforeInsert() {}

	public void afterInsert() 
	{
		List<SVMXC__Stock_Transfer__c> newList = Trigger.new;

		SMAX_PS_InventoryManager.createStockTransferEvents(newList, null);
	}
	public void beforeUpdate() {}
	public void afterUpdate() 
	{
		List<SVMXC__Stock_Transfer__c> newList = Trigger.new;
		Map<Id, SVMXC__Stock_Transfer__c> oldMap = (Map<Id, SVMXC__Stock_Transfer__c>) Trigger.oldMap;

		SMAX_PS_InventoryManager.createStockTransferEvents(newList, oldMap);
	}
	public void beforeDelete() {}
	public void afterDelete() {}
	public void afterUndelete() {}
}