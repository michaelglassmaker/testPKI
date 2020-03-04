public with sharing class SMAX_PS_TechnicianManager {

	private SMAX_PS_TechnicianManager() { }

	public static void updateTechnicianLocations(List<SVMXC__Service_Group_Members__c> techList, Map<Id, SVMXC__Service_Group_Members__c> oldMap)
	{
		if (!SMAX_PS_Utility.isActive('Update Technician Locations', 'Update Technicians Inventory Location.'))
		{
			return;
		}

		Set<String> locExtIds = new Set<String>();
		List<SVMXC__Service_Group_Members__c> techsToUpdate = new List<SVMXC__Service_Group_Members__c>();
		for (SVMXC__Service_Group_Members__c tech : techList)
		{
			SVMXC__Service_Group_Members__c old = (oldMap == null) ? null : oldMap.get(tech.Id);
			if (String.isNotEmpty(tech.SMAX_PS_Plant__c) && String.isNotEmpty(tech.SMAX_PS_LocationCode__c)
				&& (old == null || tech.SVMXC__Inventory_Location__c == null
					|| tech.SVMXC__Salesforce_User__c != old.SVMXC__Salesforce_User__c
					|| tech.SMAX_PS_Plant__c != old.SMAX_PS_Plant__c
					|| tech.SMAX_PS_LocationCode__c != old.SMAX_PS_LocationCode__c))
			{
				techsToUpdate.add(tech);
				locExtIds.add(getLocExtId(tech));
			}
		}

		if (locExtIds.isEmpty())
		{
			return;
		}

		// Lookup Locations (do we need to filter by RecordType?)
		Map<String, SVMXC__Site__c> locMap = new Map<String, SVMXC__Site__c>();
		for (SVMXC__Site__c loc : [SELECT Id, Name, SVMX_PS_External_ID__c, SVMXC__Service_Engineer__c 
			FROM SVMXC__Site__c WHERE SVMX_PS_External_ID__c IN :locExtIds])
		{
			locMap.put(loc.SVMX_PS_External_ID__c, loc);
		}

		// Match Techs to Locations, update both objects
		Map<Id, SVMXC__Site__c> locsToUpdate = new Map<Id, SVMXC__Site__c>();
		for (SVMXC__Service_Group_Members__c tech : techsToUpdate)
		{
			String locExtId = getLocExtId(tech);
			if (locMap.containsKey(locExtId))
			{
				SVMXC__Site__c loc = locMap.get(locExtId);
				loc.SVMXC__Service_Engineer__c = tech.SVMXC__Salesforce_User__c;
				locsToUpdate.put(loc.Id, loc);

				tech.SVMXC__Inventory_Location__c = loc.Id;
			}
		}

		if (!locsToUpdate.isEmpty())
		{
			update locsToUpdate.values();
		}
	}

	private static String getLocExtId(SVMXC__Service_Group_Members__c tech)
	{
		return tech.SMAX_PS_Plant__c + tech.SMAX_PS_LocationCode__c;
	}

	public static void onTechnicianGeographies(List<SMAX_PS_Geography_Technician__c> geoTechList)
	{
		Set<Id> techIds = new Set<Id>();
		for (SMAX_PS_Geography_Technician__c geoTech : geoTechList)
		{
			techIds.add(geoTech.SMAX_PS_Technician__c);
		}

		List<SVMXC__Service_Group_Members__c> techs = [SELECT Id, Name, SMAX_PS_Technician_Geographies__c 
			FROM SVMXC__Service_Group_Members__c WHERE Id IN :techIds];

		updateTechnicianGeographies(techs);
		update techs;
	}

	// Added for JIRA: SVMXCFG-403
	public static void updateTechnicianGeographies(List<SVMXC__Service_Group_Members__c> techList)
	{
		if (!SMAX_PS_Utility.isActive('Update Technician Geographies', 'Update Technician Geographies list.'))
		{
			return;
		}

		Set<Id> techIds = new Set<Id>();
		for (SVMXC__Service_Group_Members__c tech : techList)
		{
			techIds.add(tech.Id);
		}

		Map<Id, List<String>> techGeoMap = new Map<Id, List<String>>();
		for (SMAX_PS_Geography_Technician__c geoTech : [SELECT Id, Name, SMAX_PS_Technician__c, SMAX_PS_Location__c
		FROM SMAX_PS_Geography_Technician__c WHERE SMAX_PS_Technician__c IN :techIds])
		{
			Id techId = geoTech.SMAX_PS_Technician__c;
			if (!techGeoMap.containsKey(techId))
			{
				techGeoMap.put(techId, new List<String>());
			}
			techGeoMap.get(techId).add(geoTech.SMAX_PS_Location__c);
		}

		for (SVMXC__Service_Group_Members__c tech : techList)
		{
			tech.SMAX_PS_Technician_Geographies__c = '';
			tech.SMAX_PS_Technician_Geographies_2__c = '';

			List<String> geoList = techGeoMap.get(tech.Id);
			if (geoList != null && !geoList.isEmpty())
			{
				// SVMXCFG-1136 additional logic for "Tech Geo 2" field
				//tech.SMAX_PS_Technician_Geographies__c = ('' + geoList).replace('(', '').replace(')', '');
				for (String geo : geoList)
				{
					if (String.isBlank(tech.SMAX_PS_Technician_Geographies__c))
					{
						tech.SMAX_PS_Technician_Geographies__c = geo;
					}
					else if (tech.SMAX_PS_Technician_Geographies__c.length() + 2 + geo.length() < 255)
					{
						tech.SMAX_PS_Technician_Geographies__c += ', ' + geo;
					}
					else
					{
						if (String.isBlank(tech.SMAX_PS_Technician_Geographies_2__c))
						{
							tech.SMAX_PS_Technician_Geographies_2__c = geo;
						}
						else
						{
							tech.SMAX_PS_Technician_Geographies_2__c += ', ' + geo;
							if (tech.SMAX_PS_Technician_Geographies_2__c.length() > 255)
							{
								tech.SMAX_PS_Technician_Geographies_2__c = tech.SMAX_PS_Technician_Geographies_2__c.abbreviate(255);
								break;
							}
						}

					}
				}
			}
		}
	}

	// ITSFDC-509 Update the Depot Queue Id from the Depot Queue Name
	public static void updateDepotQueues(List<SVMXC__Service_Group_Members__c> techList, Map<Id, SVMXC__Service_Group_Members__c> oldMap)
	{
		if (!SMAX_PS_Utility.isActive('Update Depot Queues', 'Update Technician Depot Queues'))
		{
			return;
		}

		Set<String> queueNames = new Set<String>();
		List<SVMXC__Service_Group_Members__c> techsToUpdate = new List<SVMXC__Service_Group_Members__c>();
		for (SVMXC__Service_Group_Members__c tech : techList)
		{
			SVMXC__Service_Group_Members__c old = (oldMap == null) ? null : oldMap.get(tech.Id);
			if (tech.BD_Depot_Queue_Name__c != null && (old == null || old.BD_Depot_Queue_Name__c != tech.BD_Depot_Queue_Name__c))
			{
				queueNames.add(tech.BD_Depot_Queue_Name__c);
				techsToUpdate.add(tech);
			}
		}

		if (queueNames.isEmpty())
		{
			return;
		}

		Map<String, Group> queueMap = new Map<String, Group>();
		List<Group> queues = [SELECT Id, Name, DeveloperName
			FROM Group WHERE Type = 'Queue' AND DeveloperName IN :queueNames];
		for (Group q : queues)
		{
			queueMap.put(q.DeveloperName, q);
		}

		for (SVMXC__Service_Group_Members__c tech : techsToUpdate)
		{
			Group q = queueMap.get(tech.BD_Depot_Queue_Name__c);
			if (q != null)
			{
				tech.BD_Depot_Queue_Id__c = q.Id;
				tech.SVMXC__Role__c = 'Depot Queue';
			}
			else
			{
				tech.addError('Could not find Queue with name: ' + tech.BD_Depot_Queue_Name__c);
			}
		}
	}
}