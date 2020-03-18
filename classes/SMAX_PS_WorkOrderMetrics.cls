/**
 * Created by frankvanloon on 2019-05-09.
 * ITSFDC-1161 (old SVMXCFG-1108) Metrics and KPI
 */
public with sharing class SMAX_PS_WorkOrderMetrics
{
	public static String SAP_SYS_STATUS_TECO = 'TECO';
	public static String ORDER_TYPE_REPAIR = 'Repair';
	public static String ORDER_STATUS_READY = 'Ready for Review';
	public static String ORDER_STATUS_INVOICED = 'Invoiced';

	public static RecordType FIELD_SERVICE_RT = SMAX_PS_Utility.getRecordType('SVMXC__Service_Order__c', 'Field_Service');
	public static RecordType REMOTE_RT = SMAX_PS_Utility.getRecordType('SVMXC__Service_Order__c', 'Remote');

	public static String getExternalId(SVMXC__Service_Order__c wo, String type)
	{
		return wo.Name + '__' + type;
	}

	public static SMAX_PS_Work_Order_Metrics__c getMetrics(SVMXC__Service_Order__c wo, String type, Map<String, SMAX_PS_Work_Order_Metrics__c> metrics)
	{
		String externalId = getExternalId(wo, type);
		SMAX_PS_Work_Order_Metrics__c wom = metrics.get(externalId);
		if (wom == null)
		{
			wom = new SMAX_PS_Work_Order_Metrics__c(Name = externalId, SMAX_PS_External_Id__c = externalId,
					SMAX_PS_Work_Order__c = wo.Id, SMAX_PS_Metrics_Type__c = type);
			metrics.put(externalId, wom);
		}
		return wom;
	}

	/**
	 * Should be called from the AFTER INSERT & BEFORE UPDATE Triggers
	 */
	public static void countAssignments(List<SVMXC__Service_Order__c> woList, Map<Id, SVMXC__Service_Order__c> oldMap)
	{
		// Number of Assignments [SMAX_PS_Number_of_Assignments__c] "Dispatch Efficiency"
		// Increment Number of Times Assigned by 1 for each assignment. (not TECO.. on assign)
		Set<String> externalIds = new Set<String>();
		List<SVMXC__Service_Order__c> assignedList = new List<SVMXC__Service_Order__c>();
		for (SVMXC__Service_Order__c wo : woList)
		{
			SVMXC__Service_Order__c old = (oldMap == null) ? null : oldMap.get(wo.Id);
			if ((wo.RecordTypeId == FIELD_SERVICE_RT.Id || wo.RecordTypeId == REMOTE_RT.Id)
					&& (old == null || wo.SVMXC__Group_Member__c != old.SVMXC__Group_Member__c)
					&& wo.SVMXC__Group_Member__c != null)
			{
				String type = (wo.RecordTypeId == REMOTE_RT.Id) ? REMOTE_RT.DeveloperName : FIELD_SERVICE_RT.DeveloperName;
				externalIds.add(getExternalId(wo, type));
				assignedList.add(wo);
			}
		}

		if (assignedList.isEmpty())
		{
			return;
		}

		Map<String, SMAX_PS_Work_Order_Metrics__c> metrics = new Map<String, SMAX_PS_Work_Order_Metrics__c>();
		for (SMAX_PS_Work_Order_Metrics__c m : [SELECT Id, Name, SMAX_PS_External_Id__c,
				SMAX_PS_Number_of_Assignments__c, SMAX_PS_First_Assigned_Datetime__c
		FROM SMAX_PS_Work_Order_Metrics__c WHERE SMAX_PS_External_Id__c IN :externalIds])
		{
			metrics.put(m.SMAX_PS_External_Id__c, m);
		}

		for (SVMXC__Service_Order__c wo : assignedList)
		{
			String type = (wo.RecordTypeId == REMOTE_RT.Id) ? REMOTE_RT.DeveloperName : FIELD_SERVICE_RT.DeveloperName;
			SMAX_PS_Work_Order_Metrics__c wom = getMetrics(wo, type, metrics);

			if (wom.SMAX_PS_Number_of_Assignments__c == null)
			{
				wom.SMAX_PS_Number_of_Assignments__c = 0;
			}
			wom.SMAX_PS_Number_of_Assignments__c = wom.SMAX_PS_Number_of_Assignments__c + 1;
			if (wom.SMAX_PS_First_Assigned_Datetime__c == null)
			{
				wom.SMAX_PS_First_Assigned_Datetime__c = Datetime.now();
			}
		}

		upsertMetrics(metrics.values(), 'countAssignments');
	}

	/**
	 * Should be called from the AFTER INSERT & AFTER UPDATE Triggers
	 */
	public static void calculateMetricsOnTECO(List<SVMXC__Service_Order__c> woList, Map<Id, SVMXC__Service_Order__c> oldMap)
	{
		Set<String> externalIds = new Set<String>();
		List<SVMXC__Service_Order__c> tecoList = new List<SVMXC__Service_Order__c>();
		Set<Id> woIds = new Set<Id>();
		for (SVMXC__Service_Order__c wo : woList)
		{
			SVMXC__Service_Order__c old = (oldMap == null) ? null : oldMap.get(wo.Id);
			if ((old == null || wo.SMAX_PS_SAP_SystemStatus__c != old.SMAX_PS_SAP_SystemStatus__c)
				&& wo.SMAX_PS_SAP_SystemStatus__c == SAP_SYS_STATUS_TECO
				&& wo.RecordTypeId == FIELD_SERVICE_RT.Id)
			{
				tecoList.add(wo);
				woIds.add(wo.Id);
				externalIds.add(getExternalId(wo, FIELD_SERVICE_RT.DeveloperName));
			}
		}

		if (tecoList.isEmpty())
		{
			return;
		}

		Map<String, SMAX_PS_Work_Order_Metrics__c> metrics = new Map<String, SMAX_PS_Work_Order_Metrics__c>();
		for (SMAX_PS_Work_Order_Metrics__c m : [SELECT Id, Name, SMAX_PS_External_Id__c, SMAX_PS_First_Labor_DateTime__c, SMAX_PS_Last_Labor_Datetime__c,
				SMAX_PS_First_Assigned_Datetime__c, SMAX_PS_Case_Opened_Datetime__c, SMAX_PS_Completed_Datetime__c,
				SMAX_PS_Calculated_Dispatch_Time__c, SMAX_PS_Calc_Onsite_Response_Time__c,
				SMAX_PS_Calculated_Downtime__c, SMAX_PS_Calc_Call_Upload_Time__c, SMAX_PS_Is_First_Time_Fix__c
			FROM SMAX_PS_Work_Order_Metrics__c WHERE SMAX_PS_External_Id__c IN :externalIds])
		{
			metrics.put(m.SMAX_PS_External_Id__c, m);
		}

		Map<Id, AggregateResult> woDates = new Map<Id, AggregateResult>();
		for (AggregateResult aggResult : [SELECT SVMXC__Service_Order__c,
				MIN(SVMXC__Start_Date_and_Time__c) FirstLabor, MAX(SVMXC__End_Date_and_Time__c) LastLabor
			FROM SVMXC__Service_Order_Line__c
			WHERE SVMXC__Service_Order__c IN :woIds AND SVMXC__Line_Type__c = 'Labor'
			AND RecordType.DeveloperName = 'UsageConsumption'
			GROUP BY SVMXC__Service_Order__c])
		{
			woDates.put((Id)aggResult.get('SVMXC__Service_Order__c'), aggResult);
		}

		Map<Id, BusinessHours> bizHoursMap = SMAX_PS_BusinessHours.lookupWorkOrderBusinessHours(woIds);

		for (SVMXC__Service_Order__c wo : tecoList)
		{
			SMAX_PS_Work_Order_Metrics__c wom = getMetrics(wo, FIELD_SERVICE_RT.DeveloperName, metrics);

			// Copy fields from WO:
			wom.SMAX_PS_Case_Opened_Datetime__c = wo.SVMX_PS_Case_Opened_Date_Time__c;
			wom.SMAX_PS_Completed_Datetime__c = wo.SVMXC__Completed_Date_Time__c;

			AggregateResult woDateResult = woDates.get(wo.Id);
			if (woDateResult != null)
			{
				wom.SMAX_PS_First_Labor_DateTime__c = (Datetime) woDateResult.get('FirstLabor');
				wom.SMAX_PS_Last_Labor_Datetime__c = (Datetime) woDateResult.get('LastLabor');
			}

			BusinessHours bizHours = bizHoursMap.get(wo.Id);

			//Calculated Dispatch Time [SVMXC__Service_Order__c.SMAX_PS_Calculated_Dispatch_Time__c]
			//First Assigned DateTime, Created Date, and the business hours id
			wom.SMAX_PS_Calculated_Dispatch_Time__c = SMAX_PS_BusinessHours.businessHoursBetween(bizHours,
				wo.CreatedDate, wom.SMAX_PS_First_Assigned_Datetime__c);

			//Calculated On-site Response Time [SVMXC__Service_Order__c.SMAX_PS_Calc_Onsite_Response_Time__c]
			//First Labor Datetime, SVMX_PS_Case_Opened_Date_Time__c, and business hours obtained from the assigned technician
			//to be triggered when the Record Type IS NOT Remote and SAP System Status = TECO.
			wom.SMAX_PS_Calc_Onsite_Response_Time__c = SMAX_PS_BusinessHours.businessHoursBetween(bizHours,
				wom.SMAX_PS_Case_Opened_Datetime__c, wom.SMAX_PS_First_Labor_DateTime__c);

			// Calculated Downtime [SVMXC__Service_Order__c.SMAX_PS_Calculated_Downtime__c]
			//SVMX_PS_Case_Opened_Date_Time__c, Last Labor DateTime, and the business hours id
			wom.SMAX_PS_Calculated_Downtime__c = SMAX_PS_BusinessHours.businessHoursBetween(bizHours,
				wom.SMAX_PS_Case_Opened_Datetime__c, wom.SMAX_PS_Last_Labor_Datetime__c);

			// Calculated Call Upload Time [SVMXC__Service_Order__c.SMAX_PS_Calc_Call_Upload_Time__c]
			//Last Labor DateTime, SVMXC__Completed_Date_Time__c, and the business hours id
			wom.SMAX_PS_Calc_Call_Upload_Time__c = SMAX_PS_BusinessHours.businessHoursBetween(bizHours,
				wom.SMAX_PS_Last_Labor_Datetime__c, wom.SMAX_PS_Completed_Datetime__c);

			// Is First Time Fix? [SMAX_PS_Is_First_Time_Fix__c]
			//“First Labor Datetime” and “Last Labor DateTime”.  If the same DAY then output 1 if different than output 0.
			Boolean ftfSameDay = isSameDay(wom.SMAX_PS_First_Labor_DateTime__c, wom.SMAX_PS_Last_Labor_Datetime__c);
			wom.SMAX_PS_Is_First_Time_Fix__c = (ftfSameDay ? 1 : 0);
		}

		upsertMetrics(metrics.values(), 'calculateMetricsOnTECO');
	}

	/**
	 * Should be called from the AFTER UPDATE Trigger
	 */
	public static void calculateMetricsOnInvoicing(List<SVMXC__Service_Order__c> woList, Map<Id, SVMXC__Service_Order__c> oldMap)
	{
		Datetime NOW = Datetime.now();
		Set<String> externalIds = new Set<String>();
		List<SVMXC__Service_Order__c> readyList = new List<SVMXC__Service_Order__c>();
		List<SVMXC__Service_Order__c> invoicedList = new List<SVMXC__Service_Order__c>();
		Set<Id> woIds = new Set<Id>();
		for (SVMXC__Service_Order__c wo : woList)
		{
			SVMXC__Service_Order__c old = (oldMap == null) ? null : oldMap.get(wo.Id);
			if (wo.RecordTypeId == FIELD_SERVICE_RT.Id &&
				(old == null || wo.SVMXC__Order_Status__c != old.SVMXC__Order_Status__c))
			{
				if (wo.SVMXC__Order_Status__c == ORDER_STATUS_READY)
				{
					externalIds.add(getExternalId(wo, FIELD_SERVICE_RT.DeveloperName));
					//wo.SVMX_PS_Ready_to_Review_Date_Time__c = NOW;
					readyList.add(wo);
				}
				else if (wo.SVMXC__Order_Status__c == ORDER_STATUS_INVOICED)
				{
					externalIds.add(getExternalId(wo, FIELD_SERVICE_RT.DeveloperName));
					//wo.SMAX_PS_Invoiced_DateTime__c = NOW;
					invoicedList.add(wo);
					woIds.add(wo.Id);
				}
			}
		}

		if (externalIds.isEmpty())
		{
			return;
		}

		Map<String, SMAX_PS_Work_Order_Metrics__c> metrics = new Map<String, SMAX_PS_Work_Order_Metrics__c>();
		for (SMAX_PS_Work_Order_Metrics__c m : [SELECT Id, Name, SMAX_PS_External_Id__c,
				SMAX_PS_Ready_to_Review_Datetime__c, SMAX_PS_Invoiced_DateTime__c, SMAX_PS_Calc_Days_to_Invoice__c
		FROM SMAX_PS_Work_Order_Metrics__c WHERE SMAX_PS_External_Id__c IN :externalIds])
		{
			metrics.put(m.SMAX_PS_External_Id__c, m);
		}

		for (SVMXC__Service_Order__c wo : readyList)
		{
			SMAX_PS_Work_Order_Metrics__c wom = getMetrics(wo, FIELD_SERVICE_RT.DeveloperName, metrics);
			wom.SMAX_PS_Ready_to_Review_Datetime__c = NOW;
		}

		if (!invoicedList.isEmpty())
		{
			Map<Id, BusinessHours> bizHoursMap = SMAX_PS_BusinessHours.lookupWorkOrderBusinessHours(woIds);

			for (SVMXC__Service_Order__c wo : invoicedList) {
				BusinessHours bizHours = bizHoursMap.get(wo.Id);
				SMAX_PS_Work_Order_Metrics__c wom = getMetrics(wo, FIELD_SERVICE_RT.DeveloperName, metrics);
				wom.SMAX_PS_Invoiced_DateTime__c = NOW;
				// Calculated Days to Invoice [SVMXC__Service_Order__c.SMAX_PS_Calc_Days_to_Invoice__c]
				// SVMX_PS_Ready_to_Review_Date_Time__c, SMAX_PS_Invoiced_DateTime__c (IN DAYS)
				wom.SMAX_PS_Calc_Days_to_Invoice__c = SMAX_PS_BusinessHours.businessDaysBetween(bizHours,
						wom.SMAX_PS_Ready_to_Review_Datetime__c, wom.SMAX_PS_Invoiced_DateTime__c);
			}
		}

		upsertMetrics(metrics.values(), 'calculateMetricsOnInvoicing');
	}

	/**
	 * Should be called from the AFTER INSERT & BEFORE UPDATE Triggers
	 * Handles both Remote Conversion to FieldService and Remote Closed
	 */
	public static void calculateMetricsOnRemote(List<SVMXC__Service_Order__c> woList, Map<Id, SVMXC__Service_Order__c> oldMap)
	{
		Set<Id> woIds = new Set<Id>();
		List<SVMXC__Service_Order__c> closedOrConverted = new List<SVMXC__Service_Order__c>();
		Set<String> externalIds = new Set<String>();
		for (SVMXC__Service_Order__c wo : woList)
		{
			SVMXC__Service_Order__c old = (oldMap == null) ? null : oldMap.get(wo.Id);
			// Remote WO Converted to FieldService...
			if (old != null && wo.RecordTypeId == FIELD_SERVICE_RT.Id && old.RecordTypeId == REMOTE_RT.Id) {
				externalIds.add(getExternalId(wo, REMOTE_RT.DeveloperName));
				woIds.add(wo.Id);
				closedOrConverted.add(wo);
			}
			// Remote WO Closed...
			if ((old == null || old.SVMXC__Order_Status__c != wo.SVMXC__Order_Status__c)
					&& wo.RecordTypeId == REMOTE_RT.Id
					&& wo.SVMXC__Order_Status__c == 'Closed') {
				externalIds.add(getExternalId(wo, REMOTE_RT.DeveloperName));
				woIds.add(wo.Id);
				closedOrConverted.add(wo);
			}
		}

		if (closedOrConverted.isEmpty())
		{
			return;
		}

		Map<String, SMAX_PS_Work_Order_Metrics__c> metrics = new Map<String, SMAX_PS_Work_Order_Metrics__c>();
		for (SMAX_PS_Work_Order_Metrics__c m : [SELECT Id, Name, SMAX_PS_External_Id__c, SMAX_PS_First_Labor_DateTime__c, SMAX_PS_Last_Labor_Datetime__c,
				SMAX_PS_Case_Opened_Datetime__c, SMAX_PS_Remote_Fix__c,
				SMAX_PS_Calc_Tech_Support_Response_Time__c, SMAX_PS_Calculated_Downtime__c
			FROM SMAX_PS_Work_Order_Metrics__c WHERE SMAX_PS_External_Id__c IN :externalIds])
		{
			metrics.put(m.SMAX_PS_External_Id__c, m);
		}

		Map<Id, AggregateResult> woDates = new Map<Id, AggregateResult>();
		for (AggregateResult aggResult : [SELECT SVMXC__Service_Order__c,
				MIN(SVMXC__Start_Date_and_Time__c) FirstLabor, MAX(SVMXC__End_Date_and_Time__c) LastLabor
			FROM SVMXC__Service_Order_Line__c
			WHERE SVMXC__Service_Order__c IN :closedOrConverted AND SVMXC__Line_Type__c = 'Labor'
				AND RecordType.DeveloperName = 'SMAX_PS_Remote_Support'
			GROUP BY SVMXC__Service_Order__c])
		{
			woDates.put((Id)aggResult.get('SVMXC__Service_Order__c'), aggResult);
		}

		Map<Id, BusinessHours> bizHoursMap = SMAX_PS_BusinessHours.lookupWorkOrderBusinessHours(woIds);

		for (SVMXC__Service_Order__c wo : closedOrConverted)
		{
			SMAX_PS_Work_Order_Metrics__c wom = getMetrics(wo, REMOTE_RT.DeveloperName, metrics);

			// Copy fields from WO:
			wom.SMAX_PS_Case_Opened_Datetime__c = wo.SVMX_PS_Case_Opened_Date_Time__c;

			AggregateResult woDateResult = woDates.get(wo.Id);
			if (woDateResult != null)
			{
				wom.SMAX_PS_First_Labor_DateTime__c = (Datetime) woDateResult.get('FirstLabor');
				wom.SMAX_PS_Last_Labor_Datetime__c = (Datetime) woDateResult.get('LastLabor');
			}

			BusinessHours bizHours = bizHoursMap.get(wo.Id);

			//Calculated Tech Support Response Time [SVMXC__Service_Order__c.SMAX_PS_Calc_Tech_Support_Response_Time__c]
			//SVMX_PS_Case_Opened_Date_Time__c to first labor date time, and the business hours from the technician assigned
			//to the work order only when the Work Order record type is Remote and the SAP System Status = TECO
			wom.SMAX_PS_Calc_Tech_Support_Response_Time__c = SMAX_PS_BusinessHours.businessHoursBetween(bizHours,
					wom.SMAX_PS_Case_Opened_Datetime__c, wom.SMAX_PS_First_Labor_DateTime__c);

			// Calculated Downtime [SVMXC__Service_Order__c.SMAX_PS_Calculated_Downtime__c]
			//SVMX_PS_Case_Opened_Date_Time__c, Last Labor DateTime, and the business hours id
			wom.SMAX_PS_Calculated_Downtime__c = SMAX_PS_BusinessHours.businessHoursBetween(bizHours,
					wom.SMAX_PS_Case_Opened_Datetime__c, wom.SMAX_PS_Last_Labor_Datetime__c);

			if (wo.RecordTypeId == FIELD_SERVICE_RT.Id)
			{
				//wom.SMAX_PS_Is_Converted_to_Repair__c = 1;
				wom.SMAX_PS_Calculated_Downtime__c = null; // When converted to Field Service the DownTime calculation is reset
				wom.SMAX_PS_Remote_Fix__c = 0;
			}
			else
			{
				wom.SMAX_PS_Remote_Fix__c = 1;
			}

		}

		upsertMetrics(metrics.values(), 'calculateMetricsOnRemote');
	}

	/**
	 * Should be called from the AFTER INSERT Trigger
	 */
	public static void calculateMetricsOnCallback(List<SVMXC__Service_Order__c> woList)
	{
		Map<Id, List<SVMXC__Service_Order__c>> ipWO = new Map<Id, List<SVMXC__Service_Order__c>>();
		for (SVMXC__Service_Order__c wo : woList)
		{
			// Only run this logic if a NEW FieldService / Repair WO is being created
			if (wo.SVMXC__Component__c != null && wo.RecordTypeId == FIELD_SERVICE_RT.Id
					&& wo.SVMXC__Order_Type__c == ORDER_TYPE_REPAIR)
			{
				if (!ipWO.containsKey(wo.SVMXC__Component__c))
				{
					ipWO.put(wo.SVMXC__Component__c, new List<SVMXC__Service_Order__c>());
				}
				ipWO.get(wo.SVMXC__Component__c).add(wo);
			}
		}

		if (ipWO.isEmpty())
		{
			return;
		}

		Date afterDate = Date.today().addDays(-30);
		Map<Id, SMAX_PS_Work_Order_Metrics__c> womToUpdate = new Map<Id, SMAX_PS_Work_Order_Metrics__c>();
		// Find old WO where (Remote + Closed) OR (FS + TECO) - This is done simply by using "Last Labor".. it is only calculated in these scenarios
		for (SMAX_PS_Work_Order_Metrics__c oldWom : [SELECT Id, Name, SMAX_PS_Work_Order__c,
			SMAX_PS_Work_Order__r.SVMXC__Component__c, SMAX_PS_Last_Labor_Datetime__c, SMAX_PS_Repair_Callback_Required__c
			FROM SMAX_PS_Work_Order_Metrics__c
			WHERE SMAX_PS_Work_Order__r.SVMXC__Component__c IN :ipWO.keySet() AND SMAX_PS_Last_Labor_Datetime__c >= :afterDate])
		{
			List<SVMXC__Service_Order__c> newWorkOrders = ipWO.get(oldWom.SMAX_PS_Work_Order__r.SVMXC__Component__c);
			if (newWorkOrders != null)
			{
				for (SVMXC__Service_Order__c newWO : newWorkOrders)
				{
					// Repair Callback Required? [SVMXC__Service_Order__c.SMAX_PS_Repair_Callback_Required__c]
					// When WO created, find previous WO for same IP.. if any in < 30 days ago then "1"
					oldWom.SMAX_PS_Repair_Callback_Required__c = 1;
					womToUpdate.put(oldWom.Id, oldWom);
				}
			}
		}

		if (!womToUpdate.isEmpty())
		{
			upsertMetrics(womToUpdate.values(), 'calculateMetricsOnCallback');
		}
	}

	public static void upsertMetrics(List<SMAX_PS_Work_Order_Metrics__c> womList, String methodName)
	{
		List<SMAX_PS_ErrorLog__c> logs = new List<SMAX_PS_ErrorLog__c>();
		if (!womList.isEmpty())
		{
			Database.UpsertResult[] results = Database.upsert(womList, false);
			for (Integer i = 0; i < results.size(); i++)
			{
				Database.UpsertResult result = results[i];
				SMAX_PS_Work_Order_Metrics__c wom = womList[i];
				if (!result.isSuccess())
				{
					String errorMsg = 'Error upserting Work Order Metrics: ' + wom.Name + ' - ' + result.getErrors();
					logs.add(SMAX_PS_LogUtility.createLog(SMAX_PS_LogUtility.ERROR, errorMsg, methodName, null, wom.Id));
				}
			}
		}

		if (!logs.isEmpty())
		{
			insert logs;
		}
	}

	private static Boolean isSameDay(Datetime dt1, Datetime dt2)
	{
		return (dt1 != null && dt2 != null && dt1.year() == dt2.year() && dt1.dayOfYear() == dt2.dayOfYear());
	}
}