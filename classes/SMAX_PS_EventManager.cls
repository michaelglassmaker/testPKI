/**
 * Created by frankvanloon on 2019-04-10.
 * Marking this as "without sharing" explicitly to work-around the (dis)ability of CRC users to delete Events
 */
public without sharing class SMAX_PS_EventManager
{

	public static void deleteEvents(Set<Id> whatIds)
	{
		// SVMXCFG-1093 Delete Old Events when RE-assigned
		List<Event> oldEvents = [SELECT Id FROM Event WHERE WhatId IN :whatIds];
		if (!oldEvents.isEmpty())
		{
			delete oldEvents;
		}
	}

}