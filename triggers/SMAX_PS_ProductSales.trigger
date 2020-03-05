trigger SMAX_PS_ProductSales on SMAX_PS_ProductSales__c (before insert, before update) {
	if (Trigger.isBefore)
	{
		if (Trigger.isInsert)
		{
			SMAX_PS_ProductManager.processProductSales(Trigger.new, null);
		}
		else if (Trigger.isUpdate)
		{
			SMAX_PS_ProductManager.processProductSales(Trigger.new, Trigger.oldMap);
		}
	}
}