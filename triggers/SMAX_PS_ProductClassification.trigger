trigger SMAX_PS_ProductClassification on SMAX_PS_ProductClassification__c (after insert, after update) {
	if (Trigger.isAfter)
	{
		if (Trigger.isInsert)
		{
			SMAX_PS_ProductManager.processProductClassifications(Trigger.new, null);
		}
		else if (Trigger.isUpdate)
		{
			SMAX_PS_ProductManager.processProductClassifications(Trigger.new, Trigger.oldMap);
		}
	}	
}