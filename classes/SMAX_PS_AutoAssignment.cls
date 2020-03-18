/*
* Apex Class for WO [SVMXC__Service_Order__C] Auto Assignment Logic
* 2017-10-02 Bill Convis - Initial Creation 
* 1: For each WO passed into the Trigger - check if Auto Assign = TRUE , Check Schedule Dates
* 2: If IP has default Tech - assign to Tech
* 3. Else - follow Geography, Skill, Expertise match looking for matching Tech.
*/
public with sharing class SMAX_PS_AutoAssignment {
	private SMAX_PS_AutoAssignment() {
	}

	public static void performAutoAssignmentCheck(List<SVMXC__Service_Order__c> woList, Map<Id, SVMXC__Service_Order__c> oldMap)
	{
		if (!SMAX_PS_Utility.isActive('WO Auto Assignment', 'Perform a Auto-Assignment on the WO based on the IP or Location, and the Technician Skills and Geography.'))
			return;

		Date today = System.today();
		Date nearFuture = System.today().addDays(90);

		List<SVMXC__Service_Order__c> wosToCheck = new List<SVMXC__Service_Order__c>();
		Map<Id, Date> woScheduledDate = new Map<Id, Date>();
		Set<Id> ipIds = new Set<Id>();
		Set<Id> locIds = new Set<Id>();
		Map<Id, String> woSeriesMap = new Map<Id, String>();
		Set<String> series = new Set<String>();
		Set<String> sapTechIds = new Set<String>();
		for (SVMXC__Service_Order__c wo : woList)
		{
			SVMXC__Service_Order__c old = (oldMap == null) ? null : oldMap.get(wo.Id);
			// Decoupling Date incase we want to change which field we use
			Date newDate = wo.SVMXC__Scheduled_Date__c;
			Date oldDate = (old == null) ? null : old.SVMXC__Scheduled_Date__c;
			// Status is Open & PerformAutoAssign is checked & Date in near future & Technician is blank & either IP or Series not blank
			if (wo.SMAX_PS_Perform_Auto_Assignment__c == true //&& newDate != null && newDate >= today && newDate <= nearFuture
				&& wo.SVMXC__Order_Status__c == 'Open'
				&& wo.SVMXC__Group_Member__c == null
				//&& (wo.SVMXC__Component__c != null || wo.SMAX_PS_ProductSeries__c != null)
				&& (old == null 
					|| wo.SMAX_PS_Perform_Auto_Assignment__c != old.SMAX_PS_Perform_Auto_Assignment__c
					|| wo.SVMXC__Group_Member__c != old.SVMXC__Group_Member__c
					|| wo.SVMXC__Order_Status__c != old.SVMXC__Order_Status__c
					|| newDate != oldDate) )
			{
				wosToCheck.add(wo);
				woScheduledDate.put(wo.Id, newDate);

				// SVMXCFG-379 - Auto-Assign to SAP Work Center / Plant
				String sapTechId = getSAP_TechId(wo);
				if (sapTechId != null)
				{
					sapTechIds.add(sapTechId);
				}

				if (wo.SMAX_PS_AutoAssignmentNotes__c == null)
					wo.SMAX_PS_AutoAssignmentNotes__c = '';
				else 
					wo.SMAX_PS_AutoAssignmentNotes__c += '\n';
				wo.SMAX_PS_AutoAssignmentNotes__c += '* WO Auto-Assign Running...';
				wo.SMAX_PS_Perform_Auto_Assignment__c = FALSE;

				if (wo.SVMXC__Component__c != null)
				{
					ipIds.add(wo.SVMXC__Component__c);
				}
				else
				{
					if (wo.SVMXC__Site__c != null)
					{
						locIds.add(wo.SVMXC__Site__c);
					}
					else
					{
						wo.SMAX_PS_AutoAssignmentNotes__c += ' No IP or Location on Work Order.';
					}

					if (wo.SMAX_PS_ProductSeries__c != null)
					{
						series.add(wo.SMAX_PS_ProductSeries__c);
						woSeriesMap.put(wo.Id, wo.SMAX_PS_ProductSeries__c);
					}
					else
					{
						wo.SMAX_PS_AutoAssignmentNotes__c += ' No IP or Model Series on Work Order.';
					}
				}
			}
		}

		List<Event> events = new List<Event>();

		// SVMXCFG-379 - Auto-Assign to SAP Work Center / Plant
		Map<String, SVMXC__Service_Group_Members__c> sapTechMap = new Map<String, SVMXC__Service_Group_Members__c>();
		if (!sapTechIds.isEmpty())
		{
			// SVMXCFG-856 Auto-Assign to SAP Work Center (only)
			//for (SVMXC__Service_Group_Members__c tech : [SELECT Id, Name, SVMX_PS_External_ID__c, SVMXC__Salesforce_User__c, 
			//	SVMXC__Zip__c, SVMXC__Service_Group__c, SVMXC__Active__c, SVMXC__Enable_Scheduling__c
			//	FROM SVMXC__Service_Group_Members__c WHERE SVMX_PS_External_ID__c IN :sapTechIds])
			//{
			//	sapTechMap.put(tech.SVMX_PS_External_ID__c, tech);
			//}
			for (SVMXC__Service_Group_Members__c tech : [SELECT Id, Name, SMAX_PS_Work_Center__c, SVMXC__Salesforce_User__c, 
				SVMXC__Zip__c, SVMXC__Service_Group__c, SVMXC__Active__c, SVMXC__Enable_Scheduling__c
				FROM SVMXC__Service_Group_Members__c WHERE SMAX_PS_Work_Center__c IN :sapTechIds])
			{
				sapTechMap.put(tech.SMAX_PS_Work_Center__c, tech);
			}

			for (SVMXC__Service_Order__c wo : wosToCheck)
			{
				String sapTechId = getSAP_TechId(wo);
				if (sapTechId != null)
				{
					SVMXC__Service_Group_Members__c tech = sapTechMap.get(sapTechId);
					if (tech != null)
					{
						// SVMXCFG-693 Only assign if "Active" & "Enable Scheduling"
						if (tech.SVMXC__Active__c == FALSE || tech.SVMXC__Enable_Scheduling__c == FALSE)
						{
							wo.SMAX_PS_AutoAssignmentNotes__c += ' Skipped SAP Work Center Technician because not Active or Enabled for Scheduling.';
						}
						else
						{
							Date scheduledDate = woScheduledDate.get(wo.Id);
							Event evt = assignTechnician(wo, tech, scheduledDate, null);
							if (evt != null)
								events.add(evt);
							wo.SMAX_PS_AutoAssignmentNotes__c += ' Assigned to SAP Work Center Technician.';
						}
					}
				}
			}

			wosToCheck = filterAssigned(wosToCheck);
		}

		Map<Id, SVMXC__Installed_Product__c> ipMap = null;
		Map<Id, SVMXC__Site__c> locMap = null;
		if (!wosToCheck.isEmpty())
		{
			//Get all the Installed Products and the Default Tech Setting - put in Map
			if (!ipIds.isEmpty())
			{
				ipMap = new Map<Id, SVMXC__Installed_Product__c>([Select Id, 
						SVMXC__Preferred_Technician__c, SVMXC__Preferred_Technician__r.Name, SVMXC__Preferred_Technician__r.SVMXC__Service_Group__c,
						SVMXC__Preferred_Technician__r.SVMXC__Zip__c, SVMXC__Preferred_Technician__r.SVMXC__Salesforce_User__c,
						SVMXC__Preferred_Technician__r.SVMXC__Active__c, SVMXC__Preferred_Technician__r.SVMXC__Enable_Scheduling__c,
						SVMXC__Site__c, SVMXC__Site__r.SVMXC__Zip__c, SVMXC__Site__r.SMAX_PS_Geography__c,
						SVMXC__Product__c, SMAX_PS_ModelSeries__c
					  FROM SVMXC__Installed_Product__c where Id IN :ipIds]);
			}

			if (!locIds.isEmpty())
			{
				locMap = new Map<Id, SVMXC__Site__c>([Select Id, SVMXC__Zip__c, SMAX_PS_Geography__c
					  FROM SVMXC__Site__c where Id IN :locIds]);
			}
		}

		Set<Id> geoIds = new Set<Id>();
		Map<Id, Id> woGeoMap = new Map<Id, Id>();
		// Second pass.. try to assign to Preferred if possible.. else collect geo and skills
		for (SVMXC__Service_Order__c wo : wosToCheck)
		{
			Date scheduledDate = woScheduledDate.get(wo.Id);
			SVMXC__Installed_Product__c ip = (wo.SVMXC__Component__c != null && ipMap != null) ? 
				ipMap.get(wo.SVMXC__Component__c) : null;
			if (ip != null)
			{
				SVMXC__Service_Group_Members__c tech = (ip.SVMXC__Preferred_Technician__c != null) ? ip.SVMXC__Preferred_Technician__r : null;
				Boolean enabled = (tech != null && tech.SVMXC__Active__c == TRUE && tech.SVMXC__Enable_Scheduling__c == TRUE);
				// SVMXCFG-693 Only assign if "Active" & "Enable Scheduling"
				if (tech != null && !enabled)
				{
					wo.SMAX_PS_AutoAssignmentNotes__c += ' Skipped IP Preferred Technician because not Active or Enabled for Scheduling.';
				}

				if (tech != null && enabled)
				{
					Event evt = assignTechnician(wo, tech, scheduledDate, null);
					if (evt != null)
						events.add(evt);
					wo.SMAX_PS_AutoAssignmentNotes__c += ' Assigned to IP Preferred Technician.';
				}
				else
				{
					if (ip.SVMXC__Site__c != null && ip.SVMXC__Site__r.SMAX_PS_Geography__c != null)
					{
						geoIds.add(ip.SVMXC__Site__r.SMAX_PS_Geography__c);
						woGeoMap.put(wo.Id, ip.SVMXC__Site__r.SMAX_PS_Geography__c);
					}
					else
					{
						wo.SMAX_PS_AutoAssignmentNotes__c += ' No IP Location / Geography Found.';
					}

					if (ip.SMAX_PS_ModelSeries__c != null)
					{
						series.add(ip.SMAX_PS_ModelSeries__c);
						woSeriesMap.put(wo.Id, ip.SMAX_PS_ModelSeries__c);
					}
					else
					{
						wo.SMAX_PS_AutoAssignmentNotes__c += ' No Model Series (Skill) Found on the IP.';
					}
				}
			}
			else
			{
				SVMXC__Site__c loc = (locMap != null && wo.SVMXC__Site__c != null) ?
					locMap.get(wo.SVMXC__Site__c) : null;
				if (loc != null && loc.SMAX_PS_Geography__c != null)
				{
					geoIds.add(loc.SMAX_PS_Geography__c);
					woGeoMap.put(wo.Id, loc.SMAX_PS_Geography__c);
				}
				else
				{
					wo.SMAX_PS_AutoAssignmentNotes__c += ' No Location / Geography Found.';
				}
			}
		}

		wosToCheck = filterAssigned(wosToCheck);

		Set<Id> techIds = new Set<Id>();
		Map<Id, List<SMAX_PS_Geography_Technician__c>> geoTechMap = new Map<Id, List<SMAX_PS_Geography_Technician__c>>();
		Map<Id, SVMXC__Service_Group_Members__c> techMap = null;
		if (!wosToCheck.isEmpty())
		{
			// Get all the Geo-Technicians by Geography
			for (SMAX_PS_Geography_Technician__c geoTech : [SELECT Id, SMAX_PS_Geography__c, SMAX_PS_Technician__c, SMAX_PS_Rank__c
				FROM SMAX_PS_Geography_Technician__c WHERE SMAX_PS_Geography__c IN :geoIds ORDER BY SMAX_PS_Rank__c])
			{
				if (!geoTechMap.containsKey(geoTech.SMAX_PS_Geography__c))
					geoTechMap.put(geoTech.SMAX_PS_Geography__c, new List<SMAX_PS_Geography_Technician__c>());
				geoTechMap.get(geoTech.SMAX_PS_Geography__c).add(geoTech);

				techIds.add(geoTech.SMAX_PS_Technician__c);
			}

			// Get all the Technicians and (relevant) Expertise
			// SVMXCFG-693 Filter the NON "Active" & "Enable Scheduling"
			techMap = new Map<Id, SVMXC__Service_Group_Members__c>(
				[SELECT Id, Name, SVMXC__Salesforce_User__c, SVMXC__Zip__c, SVMXC__Service_Group__c,
					SVMXC__Service_Group__r.SMAX_PS_Is_Enterprise__c,
					(SELECT Id, SVMXC__Skill__c, SVMXC__Skill__r.Name, SVMXC__Skill__r.SVMX_PS_Skill_External_ID__c, SVMXC__Skill_Level__c 
						FROM SVMXC__Service_Group_Skills__r WHERE SVMXC__Skill__r.SVMX_PS_Skill_External_ID__c IN :series
						ORDER BY SVMXC__Skill_Level__c DESC) 
				FROM SVMXC__Service_Group_Members__c WHERE Id IN :techIds AND SVMXC__Active__c = TRUE AND SVMXC__Enable_Scheduling__c = TRUE]);
		}

		// Third pass.. try to assign based on geo and skill
		for (SVMXC__Service_Order__c wo : wosToCheck)
		{
			Date scheduledDate = woScheduledDate.get(wo.Id);
			//if (scheduledDate < Date.today().addDays(14))
			//{
			//    wo.SMAX_PS_AutoAssignmentNotes__c += ' WO within next 2 weeks. Stopped processing.';
			//    continue;
			//}

			Id geoId = woGeoMap.get(wo.Id);
			if (geoId == null)
			{
				wo.SMAX_PS_AutoAssignmentNotes__c += ' Cannot perform auto-assignment without Geography.';
				continue;
			}

			List<SMAX_PS_Geography_Technician__c> geoTechs = geoTechMap.get(geoId);
			if (geoTechs == null || geoTechs.isEmpty())
			{
				wo.SMAX_PS_AutoAssignmentNotes__c += ' Cannot perform auto-assignment without Geography-Technicians for Geography: ' + geoId;
				continue;
			}

			// SVMXCFG-693 Do not assign by Geo Only.. no "Model Series", no assignment.. 
			String modelSeries = woSeriesMap.get(wo.Id);
			if (modelSeries == null)
			{
				wo.SMAX_PS_AutoAssignmentNotes__c += ' Cannot perform auto-assignment without IP Skill.';
				continue;
			}

			for (SMAX_PS_Geography_Technician__c geoTech : geoTechs)
			{
				SVMXC__Service_Group_Members__c tech = techMap.get(geoTech.SMAX_PS_Technician__c);
				if (tech == null)
					continue;

				if (tech.SVMXC__Service_Group__r.SMAX_PS_Is_Enterprise__c != wo.SMAX_PS_Is_Enterprise__c)
				{
					// SVMXCFG-693 Only assign if WO & ServiceTeam "Is Enterprise" match
					continue;
				}

				//if (modelSeries == null)
				//{
				//	// Bypass Skill check.. assign to first Technician
				//	Event evt = assignTechnician(wo, tech, scheduledDate, null);
				//	if (evt != null)
				//		events.add(evt);
				//	wo.SMAX_PS_AutoAssignmentNotes__c += ' Assigned to closest Technician, no Skill check.';
				//	break;
				//}

				for (SVMXC__Service_Group_Skills__c expertise : tech.SVMXC__Service_Group_Skills__r)
				{
					String skillName = expertise.SVMXC__Skill__r.SVMX_PS_Skill_External_ID__c;
					if (skillName != null && skillName.equalsIgnoreCase(modelSeries))
					{
						Event evt = assignTechnician(wo, tech, scheduledDate, expertise);
						if (evt != null)
							events.add(evt);
						wo.SMAX_PS_AutoAssignmentNotes__c += ' Assigned to closest Technician, with matching Skill: ' + modelSeries;
						break;
					}
				}

				if (wo.SVMXC__Group_Member__c != null)
					break;  // Exit for "geoTechs"
			}

			if (wo.SVMXC__Group_Member__c == null)
			{
				wo.SMAX_PS_AutoAssignmentNotes__c += ' Could not find a matching Technician for Geography: ' + geoId + ' and Skill: ' + modelSeries;
				continue;
			}
		}

		if (!events.isEmpty())
			insert events;

		// NOTE: Could add a trim function to wo.SMAX_PS_AutoAssignmentNotes__c if necessary
	}

	private static List<SVMXC__Service_Order__c> filterAssigned(List<SVMXC__Service_Order__c> woList)
	{
		List<SVMXC__Service_Order__c> result = new List<SVMXC__Service_Order__c>();
		for (SVMXC__Service_Order__c wo : woList)
		{
			if (wo.SVMXC__Group_Member__c == null)
				result.add(wo);
		}
		return result;
	}

	private static Set<String> IGNORE_WORK_CENTERS = new Set<String> { 'SCHEDULE', 'OS_SCHED' };

	private static String getSAP_TechId(SVMXC__Service_Order__c wo)
	{
		// SVMXCFG-856 Auto-Assign to SAP Work Center (only)
		if (String.isNotBlank(wo.SMAX_PS_SAP_Work_Center__c))// && String.isNotBlank(wo.SMAX_PS_SAP_Maintenance_Plant__c))
		{
			if (IGNORE_WORK_CENTERS.contains(wo.SMAX_PS_SAP_Work_Center__c.toUpperCase()))
				return null;

			//return wo.SMAX_PS_SAP_Maintenance_Plant__c + wo.SMAX_PS_SAP_Work_Center__c;
			return wo.SMAX_PS_SAP_Work_Center__c;
		}
		return null;
	}

	public static Event assignTechnician(SVMXC__Service_Order__c wo, SVMXC__Service_Group_Members__c tech, Date d, SVMXC__Service_Group_Skills__c expertise)
	{
		// Added to prevent recursive update of WO from new Event
		WO_IDS_SYNCHRONIZED.add(wo.Id);

		wo.SVMXC__Group_Member__c = tech.Id;
		wo.SVMXC__Service_Group__c = tech.SVMXC__Service_Group__c;
		if (tech.SVMXC__Salesforce_User__c != null)
			wo.OwnerId = tech.SVMXC__Salesforce_User__c;
		wo.SVMXC__Order_Status__c = 'Assigned';
		wo.SMAX_PS_Tech_Expertise__c = (expertise == null) ? null : expertise.Id;

		if (d == null)
			d = Date.today();
		Datetime startTime = Datetime.newInstance(d.year(), d.month(), d.day(), 9, 0, 0);
		// TODO: Shift timezone...
		wo.SVMXC__Scheduled_Date_Time__c = startTime;

		// Event on the Calendar?
		Event evt = null;
		if (tech.SVMXC__Salesforce_User__c != null)
		{
			evt = new Event();
			evt.StartDateTime=startTime;
			if (wo.SVMXC__SM_Scheduled_Duration__c == null || wo.SVMXC__SM_Scheduled_Duration__c == 0)
			{
				evt.EndDateTime=startTime.addHours(3);
			}
			else
			{
				Integer minutes = (wo.SVMXC__SM_Scheduled_Duration__c * 60).round().intValue();
				evt.EndDateTime = startTime.addMinutes(minutes);
			}
			evt.SVMXC__Driving_Time__c = 60; // Default all to 1 Hour of Drive Time
			evt.Subject=wo.Name + ';' + wo.SVMXC__Billing_Type__c + ';' + wo.SVMXC__Order_Type__c + ';' + wo.SVMX_PS_Problem_Summary__c;
			if(evt.Subject.length() > 255) evt.Subject = evt.Subject.substring(0, 252) + '...';
			evt.OwnerId=tech.SVMXC__Salesforce_User__c;
			evt.WhatId=wo.Id;
		}

		return evt;
	}
	/**
	 *	Finishes Assignment when custom is logic is used to partially assign.
	 *	Should be called from BEFORE UPDATE
	 */
	public static void finishAssignment(List<SVMXC__Service_Order__c> woList, Map<Id, SVMXC__Service_Order__c> oldMap)
	{
		RecordType pendingRT = SMAX_PS_Utility.getRecordType('SVMXC__Service_Order__c', 'Enterprise_Pending_IP');
		if (pendingRT == null)
			return;

		Set<Id> techIds = new Set<Id>();
		List<SVMXC__Service_Order__c> wosToUpdate = new List<SVMXC__Service_Order__c>();
		for (SVMXC__Service_Order__c wo : woList)
		{
			SVMXC__Service_Order__c old = (oldMap == null) ? null : oldMap.get(wo.Id);
			if (wo.RecordTypeId == pendingRT.Id && wo.SVMXC__Group_Member__c != null 
				&& (old == null || wo.SVMXC__Group_Member__c != old.SVMXC__Group_Member__c))
			{
				// SVMXCFG-682 Found one to update.. assign Owner
				wosToUpdate.add(wo);
				techIds.add(wo.SVMXC__Group_Member__c);
			}
		}

		if (techIds.isEmpty())
			return;

		Map<Id, SVMXC__Service_Group_Members__c> techMap = new Map<Id, SVMXC__Service_Group_Members__c>(
			[SELECT Id, Name, SVMXC__Salesforce_User__c 
			FROM SVMXC__Service_Group_Members__c WHERE Id IN :techIds]);
		for (SVMXC__Service_Order__c wo : wosToUpdate)
		{
			SVMXC__Service_Group_Members__c tech = techMap.get(wo.SVMXC__Group_Member__c);
			if (tech != null && tech.SVMXC__Salesforce_User__c != null)
			{
				wo.OwnerId = tech.SVMXC__Salesforce_User__c;
			}
		}
	}

	/**
		Synchronization of Work Order Scheduled Datetime / Duration to Event Start / End Datetimes
	 */

	private static Set<Id> WO_IDS_SYNCHRONIZED = new Set<Id>();

	// SHOULD ONLY BE USED IN UNIT TESTS TO CLEAR STATIC VALUES
	public static void clearSynchronizedList()
	{
		WO_IDS_SYNCHRONIZED.clear();
	}

	/**
	 * Build-Card: BC-05272
	 * When the WO "Scheduled Datetime" is changed, update the corresponding Calendar Event Start Time
	 */ 
	public static void confirmScheduling(List<SVMXC__Service_Order__c> woList, Map<Id, SVMXC__Service_Order__c> oldMap)
	{
		Set<Id> techIds = new Set<Id>();
		Map<Id, SVMXC__Service_Order__c> woToReschedule = new Map<Id, SVMXC__Service_Order__c>();
		for (SVMXC__Service_Order__c wo : woList)
		{
			SVMXC__Service_Order__c old = (oldMap == null) ? null : oldMap.get(wo.Id);

			if (old != null && wo.SVMXC__Service_Duration__c != old.SVMXC__Service_Duration__c)
			{
				Long seconds = wo.SVMXC__Service_Duration__c.longValue();
				Long minutes = seconds / 60;
				Decimal hours = (minutes / 60.00).setScale(2);
				wo.SVMXC__SM_Scheduled_Duration__c = hours;
			}

			if (old != null && wo.SVMXC__Scheduled_Date_Time__c != null
				&& old.SVMXC__Scheduled_Date_Time__c != null
				&& (wo.SVMXC__Scheduled_Date_Time__c != old.SVMXC__Scheduled_Date_Time__c
					|| wo.SVMXC__SM_Scheduled_Duration__c != old.SVMXC__SM_Scheduled_Duration__c)
				&& wo.SVMXC__Group_Member__c != null)
			{
				if (WO_IDS_SYNCHRONIZED.contains(wo.Id))
					continue;

				WO_IDS_SYNCHRONIZED.add(wo.Id);
				woToReschedule.put(wo.Id, wo);
				techIds.add(wo.SVMXC__Group_Member__c);
			}
		}

		if (woToReschedule.isEmpty() || techIds.isEmpty())
		{
			return;
		}

		// SVMXCFG-1075 WO with multiple Event assignments - Only change assigned Technician's events
		Map<Id, SVMXC__Service_Group_Members__c> techMap = new Map<Id, SVMXC__Service_Group_Members__c>(
			[SELECT Id, Name, SVMXC__Salesforce_User__c, SVMXC__Salesforce_User__r.IsActive
				FROM SVMXC__Service_Group_Members__c WHERE Id IN :techIds]);
		Set<Id> userIds = new Set<Id>();
		for (SVMXC__Service_Group_Members__c tech : techMap.values())
		{
			if (tech.SVMXC__Salesforce_User__c != null && tech.SVMXC__Salesforce_User__r.IsActive)
			{
				userIds.add(tech.SVMXC__Salesforce_User__c);
			}
		}

		if (userIds.isEmpty())
		{
			return; // No User Ids for Events anyway.. exit
		}

		System.debug('AUTO-SCHED: Trying to reschedule WO Events: ' + woToReschedule.keySet());
		List<Event> eventsToUpdate = new List<Event>();
		for (Event evt : [SELECT Id, StartDateTime, WhatId, OwnerId
			FROM Event WHERE WhatId IN :woToReschedule.keySet() AND OwnerId IN :userIds])
		{
			SVMXC__Service_Order__c wo = woToReschedule.get(evt.WhatId);
			SVMXC__Service_Order__c old = oldMap.get(wo.Id);
			SVMXC__Service_Group_Members__c tech = techMap.get(wo.SVMXC__Group_Member__c);
			Id userId = tech.SVMXC__Salesforce_User__c;

			if (userId != null && userId == evt.OwnerId
				&& old.SVMXC__Scheduled_Date_Time__c == evt.StartDateTime)
			{
				evt.StartDateTime = wo.SVMXC__Scheduled_Date_Time__c;
				if (wo.SVMXC__SM_Scheduled_Duration__c != null)
				{
					Integer minutes = (wo.SVMXC__SM_Scheduled_Duration__c * 60).round().intValue();
					evt.EndDateTime = wo.SVMXC__Scheduled_Date_Time__c.addMinutes(minutes);
				}
				eventsToUpdate.add(evt);
				System.debug('AUTO-SCHED: Rescheduled WO Event: ' + evt);
			}
		}

		if (!eventsToUpdate.isEmpty())
		{
			update eventsToUpdate;
		}
	}

	/**
	 * SVMXCFG-151 : When Events are rescheduled, update the associated Work Order (if applicable)
	 */
	public static void schedulingConfirm(List<Event> eventList, Map<Id, Event> oldMap)
	{
		List<Event> woEvents = new List<Event>();   
		Set<Id> woIds = new Set<Id>();
		String woPrefix = Schema.SObjectType.SVMXC__Service_Order__c.getKeyPrefix();
		for (Event e : eventList)
		{
			Event oldE = (oldMap == null) ? null : oldMap.get(e.Id);
			if (e.WhatId != null && ((String)e.WhatId).startsWith(woPrefix) && 
				(oldE == null || e.StartDateTime != oldE.StartDateTime || e.EndDateTime != oldE.EndDateTime))
			{
				Id woId = e.WhatId;
				if (WO_IDS_SYNCHRONIZED.contains(woId))
					continue;

				WO_IDS_SYNCHRONIZED.add(woId);
				woEvents.add(e);
				woIds.add(woId);
			}
		}

		if (woIds.isEmpty())
			return;

		System.debug('AUTO-SCHED: Trying to reschedule WOs from Events: ' + woIds);
		List<SVMXC__Service_Order__c> wosToUpdate = new List<SVMXC__Service_Order__c>();
		Map<Id, SVMXC__Service_Order__c> woMap = new Map<Id, SVMXC__Service_Order__c>([SELECT Id, Name,
			SVMXC__Scheduled_Date_Time__c, SVMXC__SM_Scheduled_Duration__c 
			FROM SVMXC__Service_Order__c WHERE Id IN :woIds]);
		for (Event e : woEvents)
		{
			Id woId = e.WhatId;
			SVMXC__Service_Order__c wo = woMap.get(woId);
			wo.SVMXC__Scheduled_Date_Time__c = e.StartDateTime;
			Long milliseconds = e.EndDateTime.getTime() - e.StartDateTime.getTime();
			Long seconds = milliseconds / 1000;
			Long minutes = seconds / 60;
			Decimal hours = (minutes / 60.00).setScale(2);
			wo.SVMXC__SM_Scheduled_Duration__c = hours;
			wosToUpdate.add(wo);
			System.debug('AUTO-SCHED: Rescheduled WO from Event: ' + wo);
		}

		if (!wosToUpdate.isEmpty())
			update wosToUpdate;
	}

	// SVMXCFG-723 - 09/05/18 - Add WO data to Calendar Events 
	public static void syncEventFields(List<Event> eventList)
	{
		List<Event> woEvents = new List<Event>();   
		Set<Id> woIds = new Set<Id>();
		String woPrefix = Schema.SObjectType.SVMXC__Service_Order__c.getKeyPrefix();
		for (Event e : eventList)
		{
			//Event oldE = (oldMap == null) ? null : oldMap.get(e.Id);
			if (e.WhatId != null && ((String)e.WhatId).startsWith(woPrefix))
			{
				Id woId = e.WhatId;
				woEvents.add(e);
				woIds.add(woId);
			}
		}

		if (woIds.isEmpty())
			return;

		Map<Id, SVMXC__Service_Order__c> woMap = new Map<Id, SVMXC__Service_Order__c>(
			[SELECT Id, Name, SVMXC__Company__c, SVMXC__Company__r.Name, SMAX_PS_ContactName__c, SVMX_PS_Contact_Phone__c,
					SVMXC__Order_Type__c, SVMXC__Component__c, SVMXC__Component__r.Name,
					RecordType.Name, SVMXC__Billing_Type__c, SVMX_PS_Problem_Summary__c
				FROM SVMXC__Service_Order__c 
				WHERE Id IN :woIds]);	

		for (Event e : woEvents)
		{
			Id woId = e.WhatId;
			SVMXC__Service_Order__c wo = woMap.get(woId);
			e.SMAX_PS_Company__c = (wo.SVMXC__Company__c == null) ? '' : wo.SVMXC__Company__r.Name;
			e.SMAX_PS_Contact_Name__c = wo.SMAX_PS_ContactName__c;
			e.SMAX_PS_Contact_Phone__c = wo.SVMX_PS_Contact_Phone__c;
			e.SMAX_PS_Order_Type__c = wo.SVMXC__Order_Type__c;
			e.SMAX_PS_Instrument__c = (wo.SVMXC__Component__c == null) ? '' : wo.SVMXC__Component__r.Name;
			e.SMAX_PS_Work_Order_Number__c = wo.Name;
			e.Description = 'Work Order Number: ' + e.SMAX_PS_Work_Order_Number__c
				+ '\n' + 'Account: ' + e.SMAX_PS_Company__c
				+ '\n' + 'Contact Name: ' + (e.SMAX_PS_Contact_Name__c == null ? '' : e.SMAX_PS_Contact_Name__c)
				+ '\n' + 'Contact Phone: ' + (e.SMAX_PS_Contact_Phone__c == null ? '' : e.SMAX_PS_Contact_Phone__c)
				+ '\n' + 'Order Type: ' + e.SMAX_PS_Order_Type__c
				+ '\n' + 'Instrument: ' + e.SMAX_PS_Instrument__c;

			e.SMAX_PS_Work_Order_Record_Type__c = wo.RecordType.Name;
			// SVMXCFG-806 : Update Event Subject Concatenation
			e.Subject=wo.Name + ';' + wo.SVMXC__Billing_Type__c + ';' + wo.SVMXC__Order_Type__c + ';' + wo.SVMX_PS_Problem_Summary__c;
			if(e.Subject.length() > 255)
				e.Subject = e.Subject.substring(0, 252) + '...';
		}
	}

	// SVMXCFG-1000 Auto-Assign for Estimates
	public static void autoAssignServiceEstimates(List<SVMXC__Service_Order__c> woList, Map<Id, SVMXC__Service_Order__c> oldMap)
	{
		if (!SMAX_PS_Utility.isActive('WO Service Estimate Auto Assign', 'Perform a Auto-Assignment on the WO when Service Estimate Record Type and Created By FSE Profile.'))
			return;

		RecordType estimateRT = SMAX_PS_Utility.getRecordType('SVMXC__Service_Order__c', 'Service_Request');
		Set<Id> userIds = new Set<Id>();
		List<SVMXC__Service_Order__c> woToAssign = new List<SVMXC__Service_Order__c>();
		for (SVMXC__Service_Order__c wo : woList)
		{
			if (wo.RecordTypeId == estimateRT.Id && wo.SVMXC__Group_Member__c == null)
			{
				// Try to assign to the current User's Technician...
				woToAssign.add(wo);
				userIds.add(wo.OwnerId);
			}
		}

		if (woToAssign.isEmpty())
			return;

		Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Name, Profile.Name FROM User WHERE Id IN :userIds]);

		Map<Id, SVMXC__Service_Group_Members__c> userTechMap = new Map<Id, SVMXC__Service_Group_Members__c>();
		for (SVMXC__Service_Group_Members__c tech : [SELECT Id, Name, SVMXC__Salesforce_User__c, SVMXC__Service_Group__c
			FROM SVMXC__Service_Group_Members__c WHERE SVMXC__Salesforce_User__c IN :userIds])
		{
			userTechMap.put(tech.SVMXC__Salesforce_User__c, tech);
		}

		List<Event> events = new List<Event>();
		for (SVMXC__Service_Order__c wo : woToAssign)
		{
			User u = userMap.get(wo.OwnerId);
			SVMXC__Service_Group_Members__c tech = userTechMap.get(wo.OwnerId);
			// SVMXCFG-1107 Null protect the User variable (could be a Group or Queue)
			if (u != null && tech != null) // && u.Profile.Name.contains('Field Engineer')
			{
				Event evt = assignTechnician(wo, tech, Date.today(), null);
				events.add(evt);
			}
		}

		if (!events.isEmpty())
			insert events;
	}

	// SVMXCFG-1103 Problem with Estimate Conversions
	public static void convertedFromEstimate(List<SVMXC__Service_Order__c> woList, Map<Id, SVMXC__Service_Order__c> oldMap)
	{
		DateTime dt = Datetime.newInstance(Date.today().addDays(1), Time.newInstance(9, 0, 0, 0));
		for (SVMXC__Service_Order__c wo : woList)
		{
			SVMXC__Service_Order__c old = (oldMap == null) ? null : oldMap.get(wo.Id);
			if (old != null && wo.SVMXC__Group_Member__c != null
				&& wo.SMAX_PS_Converted_from_Estimate__c == true
				&& old.SMAX_PS_Converted_from_Estimate__c == false)
			{
				// A WO is currently converting from a Estimate...
				wo.SVMXC__Scheduled_Date_Time__c = dt;
				System.debug('!! UPDATED Scheduled Date for converted Estimate: ' + dt);
				// NOTE: This will cause confirmScheduling(...) to run and adjust the Event as well
			}
		}
	}

	// ITSFDC-509 Auto-Assign for Depot Work Orders (when they "Accept" from the Queue)
	public static void autoAssignOwnerChanges(List<SVMXC__Service_Order__c> woList, Map<Id, SVMXC__Service_Order__c> oldMap)
	{
		if (!SMAX_PS_Utility.isActive('WO Auto Assign Owner Changes', 'Perform a Auto-Assignment to a Technician related to the new WO Owner.'))
			return;

		RecordType depotRT = SMAX_PS_Utility.getRecordType('SVMXC__Service_Order__c', 'Depot_Repair');
		Set<Id> userIds = new Set<Id>();
		List<SVMXC__Service_Order__c> woToAssign = new List<SVMXC__Service_Order__c>();
		for (SVMXC__Service_Order__c wo : woList)
		{
			SVMXC__Service_Order__c old = (oldMap == null) ? null : oldMap.get(wo.Id);
			if (wo.RecordTypeId == depotRT.Id && (old != null && wo.OwnerId != old.OwnerId))
			{
				// Try to assign to the current User's Technician...
				woToAssign.add(wo);
				userIds.add(wo.OwnerId);
			}
		}

		if (woToAssign.isEmpty())
			return;

		Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Name, Profile.Name FROM User WHERE Id IN :userIds]);

		Map<Id, SVMXC__Service_Group_Members__c> userTechMap = new Map<Id, SVMXC__Service_Group_Members__c>();
		for (SVMXC__Service_Group_Members__c tech : [SELECT Id, Name, SVMXC__Salesforce_User__c, SVMXC__Service_Group__c
			FROM SVMXC__Service_Group_Members__c WHERE SVMXC__Salesforce_User__c IN :userIds])
		{
			userTechMap.put(tech.SVMXC__Salesforce_User__c, tech);
		}

		List<Event> events = new List<Event>();
		for (SVMXC__Service_Order__c wo : woToAssign)
		{
			User u = userMap.get(wo.OwnerId);
			SVMXC__Service_Group_Members__c tech = userTechMap.get(wo.OwnerId);
			// SVMXCFG-1107 Null protect the User variable (could be a Group or Queue)
			if (u != null && tech != null)
			{
				// IF WO is still in "Initializing", don't allow this...
				if (wo.SVMXC__Order_Status__c == 'Initializing')
				{
					wo.addError('Cannot Accept the Work Order until it has finished initializing. Please check for Integration Errors.');
				}
				else
				{
					Date startDate = wo.SMAX_PS_Customer_Required_Start_Date__c;
					Event evt = assignTechnician(wo, tech, (startDate == null ? Date.today() : startDate), null);
					events.add(evt);
				}
			}
		}

		if (!events.isEmpty())
		{
			insert events;
		}
	}

}