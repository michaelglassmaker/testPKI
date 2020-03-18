trigger SMAX_PS_StockTransfer on SVMXC__Stock_Transfer__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	SMAX_PS_Utility.executeHandler(new SMAX_PS_StockTransferTriggerHandler());
}