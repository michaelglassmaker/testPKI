trigger UserTrigger on User (after insert, after update) {
	if (Trigger.isAfter)
	{
		if (Trigger.isInsert)
		{
			UserJobFamily.handleJobFamily(Trigger.New, null);
		}
		else if (Trigger.isUpdate)
		{
			UserJobFamily.handleJobFamily(Trigger.New, Trigger.OldMap);
		}
	}
}