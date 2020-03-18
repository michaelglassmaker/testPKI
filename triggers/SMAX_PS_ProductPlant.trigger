/**
 * Created by frankvanloon on 2019-11-20.
 * Added to support ITSFDC-509
 */
trigger SMAX_PS_ProductPlant on SMAX_PS_ProductPlant__c (before insert, before update) {
	if (Trigger.isBefore)
	{
		if (Trigger.isInsert)
		{
			SMAX_PS_ProductManager.processProductPlant(Trigger.new, null);
		}
		else if (Trigger.isUpdate)
		{
			SMAX_PS_ProductManager.processProductPlant(Trigger.new, Trigger.oldMap);
		}
	}

}