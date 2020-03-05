trigger AccountFunctionTrigger on Account_Function__c (before insert, before update) {

	if (Trigger.isBefore)
	{
		List<Account_Function__c> functions = Trigger.new;
		if (Trigger.isInsert)
		{
			SAP_AccountFunctions.lookupAccounts(functions, null);
		}
		else
		{
			Map<Id, Account_Function__c> oldMap = Trigger.oldMap;
			SAP_AccountFunctions.lookupAccounts(functions, oldMap);
		}
	}

}