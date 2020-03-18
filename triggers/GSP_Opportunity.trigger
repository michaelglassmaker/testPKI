trigger GSP_Opportunity on Opportunity (after delete, after insert, after update, before delete, before insert, before update)
{
	if (!GSP_TriggerContext.DisableAllTriggers && !GSP_TriggerContext.DisableOpportunityTriggers)
	{
		if (trigger.isBefore)
		{
			if (trigger.isUpdate)
			{
				Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
				for (Opportunity opportunity : trigger.new)
				{
					Opportunity oldOpportunity = trigger.oldMap.get(opportunity.Id);
					if (opportunity.CloseDate	!= oldOpportunity.CloseDate ||
						opportunity.Amount		!= oldOpportunity.Amount ||
						opportunity.OwnerId		!= oldOpportunity.OwnerId ||
						opportunity.TerritoryId != oldOpportunity.TerritoryId ||
						opportunity.IsClosed	!= oldOpportunity.IsClosed ||
						opportunity.IsWon		!= oldOpportunity.IsWon)
					{
						opportunityMap.put(opportunity.Id, opportunity);
					}
				}
				if (!opportunityMap.isEmpty())
				{
					GSP_trgOpportunityMethods.UpdateTargets(opportunityMap);
				}
			}
		}
		else
		{
			
		}
	}
}