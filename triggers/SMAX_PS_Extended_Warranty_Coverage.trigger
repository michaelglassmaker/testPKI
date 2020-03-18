/**
 * Created by frankvanloon on 2019-12-06.
 */

trigger SMAX_PS_Extended_Warranty_Coverage on BD_Extended_Warranty_Coverage__c (before insert, before update, after insert, after update) {

	if (Trigger.isBefore)
	{
		if (Trigger.isInsert)
		{

		}
		else if (Trigger.isUpdate)
		{
			SMAX_PS_ExtendedWarranty.createExtendedWarrantyWorkOrders(Trigger.new, Trigger.oldMap);
		}
	}
	else if (Trigger.isAfter)
	{
		if (Trigger.isInsert)
		{

		}
		else if (Trigger.isUpdate)
		{

		}
	}
}