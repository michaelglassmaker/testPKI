/**
 *  Apex Class for Work Order One-Click Complete / Submit Logic
 * 
 *  2018-05-09       Frank VanLoon             Initial copy of One-Click Complete
 */
 public with sharing class SMAX_PS_WorkOrderDebriefManager {
	
	public static String WORK_COMPLETE = 'Work Complete';
	public static String WORK_COMPLETE_PENDING = 'Work Complete - Pending';
	public static String WORK_COMPLETE_ERROR = 'Work Complete - Error';
 	public static String WORK_COMPLETE_MATERIAL_FOLLOW_UP = 'Work Complete - Material Follow Up';
	public static String CANCELED = 'Canceled';
	public static Set<String> NON_PRICED_WO_TYPES = new Set<String> { 'Installation', 'Internal' };

	public static Boolean IS_PROCESSING_DEBRIEF_RESPONSE = false;

	private SMAX_PS_WorkOrderDebriefManager() {}

	/**
	 *  Update the child Work Detail lines Status to "Submitted" on "One-Click Complete" OR "Submit All Lines"
	 *  NOTE: This method replaces both updateWorkDetailLineStatus(...) & addWorkCompleteError(...)
	 *  Should be called in the "before" trigger(s)
	 */
	public static void submitCompleteAll(List<SVMXC__Service_Order__c> woNewList, Map<Id, SVMXC__Service_Order__c> woOldMap)
	{
		if (!SMAX_PS_Utility.isActive('Work Order Submit Complete All', 'Update the child Work Detail lines Status to "Submitted" on "One-Click Complete" OR "Submit All Lines"'))
			return;

		if (IS_PROCESSING_DEBRIEF_RESPONSE)
			return;

		// Collect qualified Work Order Ids
		Map<Id, SVMXC__Service_Order__c> woMap = new Map<Id, SVMXC__Service_Order__c>();
		Set<Id> submitIds = new Set<Id>();
		Set<Id> completeIds = new Set<Id>();
		for (SVMXC__Service_Order__c workOrder : woNewList)
		{
			SVMXC__Service_Order__c old = (woOldMap == null) ? null : woOldMap.get(workOrder.id);
			if ( old != null && old.SMAX_PS_SubmitAllLines__c != workOrder.SMAX_PS_SubmitAllLines__c && workOrder.SMAX_PS_SubmitAllLines__c == TRUE)
			{
				woMap.put(workOrder.Id, workOrder);
				workOrder.SMAX_PS_SubmitAllLines__c=false;
				submitIds.add(workOrder.Id);
			}
			if ( old != null && old.SVMXC__Order_Status__c != workOrder.SVMXC__Order_Status__c && workOrder.SVMXC__Order_Status__c == WORK_COMPLETE)
			{
				woMap.put(workOrder.Id, workOrder);
				completeIds.add(workOrder.Id);
			}
		}

		if (woMap.isEmpty())
			return;

		String txnId = String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));

		// Get Record Type Id for Usage Consumption 
		Id usageRecTypeId = SMAX_PS_Utility.getRecordType('SVMXC__Service_Order_Line__c', 'UsageConsumption').Id;

		System.debug('SUBMIT-COMPLETE ALL Starting');

		// Select the Work Detail lines which qualify for updating
		// SVMXCFG-943 Load the Consumed From Location field: SMAX_PS_Non_Consumable_Location__c
		List<SVMXC__Service_Order_Line__c> wdList = new List<SVMXC__Service_Order_Line__c>([SELECT Id, Name, 
			SVMXC__Line_Status__c, SVMXC__Line_Type__c, SVMXC__Service_Order__c,
			SVMXC__Product__c, SMAX_PS_ContractPercentDiscount__c, SMAX_PS_IntegrationStatus__c,
			SVMXC__Consumed_From_Location__r.SMAX_PS_Non_Consumable_Location__c
			FROM SVMXC__Service_Order_Line__c WHERE SVMXC__Service_Order__c in :woMap.keySet() 
			AND RecordTypeId = :usageRecTypeId AND SVMXC__Line_Status__c!='Canceled']);

		// Fill Debrief Map
		Map<Id, DebriefDetails> debriefMap = new Map<Id, DebriefDetails>();
		for (SVMXC__Service_Order_Line__c wd : wdList) {
			if(!debriefMap.containskey(wd.SVMXC__Service_Order__c)) {
				debriefMap.put(wd.SVMXC__Service_Order__c, new DebriefDetails());
			}
			// SVMXCFG-380 - Fault Code "Required" Rule Changes... load more details
			DebriefDetails details = debriefMap.get(wd.SVMXC__Service_Order__c);
			details.allLines.add(wd);
			if (wd.SVMXC__Line_Type__c == 'Fault Code')
				details.faultCodeLines++;
			else
				details.debriefLines++;
			if (wd.SVMXC__Line_Status__c == 'Submitted' && wd.SMAX_PS_IntegrationStatus__c != 'Error')
				details.stuckLines++;
		}

		// Determine if there are any Errors to report (only for "Work Complete" WOs)
		for (Id woId : completeIds) 
		{
			SVMXC__Service_Order__c wo = woMap.get(woId);
			wo.SMAX_PS_Completion_Errors__c = null;
			List<String> errorMsgs = new List<String>();
			DebriefDetails details = (debriefMap.containsKey(wo.Id)) ? debriefMap.get(wo.Id) : new DebriefDetails();

			// SVMXCFG-366 Complaints: WO Complete Requires Fault Code
			if (details.faultCodeLines == 0)
			{
				// SVMXCFG-380: If 0 Confirmed Debrief Lines, Installation, or TPV skip this.. 
				if (details.debriefLines == 0 || wo.SMAX_PS_Is_TPV__c == TRUE) // wo.SMAX_PS_Is_Install__c == TRUE || 
				{
					System.debug('SKIPPING Fault Code Validation because NO Lines OR TPV');
				}
				else
				{
					errorMsgs.add('At least one Fault Code line must be entered when other Debrief lines are entered.');
				}
			}

			if (details.stuckLines > 0)
			{
				errorMsgs.add('Wait for the ' + details.stuckLines + ' Submitted Line(s) to finish processing.');
			}

			if (!errorMsgs.isEmpty())
			{
				String errorMsg = 'For a Work Order to transition to "Work Complete", the following must be corrected: ' + errorMsgs;
				// SVMXCFG-327 - Use a Order Status / Message field instead of Apex Errors
				//wo.addError(errorMsg);
				wo.SMAX_PS_Completion_Errors__c = errorMsg;
				wo.SVMXC__Order_Status__c = 'Work Complete - Error';
				// Remove from woMap so we don't process any more.. 
				woMap.remove(wo.Id);
			}
		}

		// SVMXCFG-335 WO Submit Lines: Skip Priced on 100% Discount Lines
		Map<Id, List<SVMXC__Service_Order_Line__c>> linesToDiscount = new Map<Id, List<SVMXC__Service_Order_Line__c>>();

		// Update Work Detail Lines Status
		//Set<Id> woIdsToSend = new Set<Id>(woMap.keySet());
		Set<Id> woIdsWithLinesToSend = new Set<Id>();
		Map<Id, List<String>> woProblems = new Map<Id, List<String>>();
		List<SVMXC__Service_Order_Line__c> wdToUpdate = new List<SVMXC__Service_Order_Line__c>();
		for (Id woId : woMap.keySet())
		{
			SVMXC__Service_Order__c wo = woMap.get(woId);
			DebriefDetails details = (debriefMap.containsKey(woId)) ? debriefMap.get(woId) : new DebriefDetails();
			for ( SVMXC__Service_Order_Line__c wd : details.allLines ) 
			{
				System.debug('SUBMIT-COMPLETE ALL WO: ' + wo);
				// SVMXCFG-943: Do not allow to complete if any "Non_Consumable" = TRUE
				if (wd.SVMXC__Consumed_From_Location__r != null &&
					wd.SVMXC__Consumed_From_Location__r.SMAX_PS_Non_Consumable_Location__c == TRUE)
				{
					if (!woProblems.containsKey(woId))
					{
						woProblems.put(woId, new List<String>());
					}
					woProblems.get(woId).add('Parts from Non-Consumable Location is not able to be Submitted: ' + wd.Name);
				}
				else if (wd.SVMXC__Line_Status__c == 'Priced'
					// SVMXINT-469 Complaints: Fault Code Integration Changes (Send Fault Codes only if not Confirmed)
					|| (wd.SVMXC__Line_Type__c == 'Fault Code' && wd.SVMXC__Line_Status__c == 'Open')
					// JIRA #392 - Internal / Installation - Skip Priced
					|| (NON_PRICED_WO_TYPES.contains(wo.SVMXC__Billing_Type__c) && wd.SVMXC__Line_Status__c == 'Open') )
				{
					wd.SVMXC__Line_Status__c='Submitted';
					wd.SMAX_PS_SubmitTxnId__c = txnId;
					wdToUpdate.add(wd);
					woIdsWithLinesToSend.add(woId);
				}
				else if (wd.SVMXC__Line_Status__c == 'Submitted' && wd.SMAX_PS_IntegrationStatus__c == 'Error')
				{
					// How should they take the line from Submitted back to Open/Error/Priced and back?
					// What do we do about lines already in Submitted?!?
					wd.SMAX_PS_IntegrationStatus__c = 'Pending';
					wd.SMAX_PS_SubmitTxnId__c = txnId;
					wdToUpdate.add(wd);
					woIdsWithLinesToSend.add(woId);
				}
				else if (wo.SMAX_PS_ContractEntitlement__c != null && wd.SVMXC__Line_Status__c == 'Open'
					&& wd.SMAX_PS_ContractPercentDiscount__c == null)
				{
					if (!linesToDiscount.containsKey(wo.Id))
						linesToDiscount.put(wo.Id, new List<SVMXC__Service_Order_Line__c>());
					linesToDiscount.get(wo.Id).add(wd);
				}
				else if (wd.SVMXC__Line_Status__c != 'Confirmed')
				{
					if (!woProblems.containsKey(woId))
						woProblems.put(woId, new List<String>());
					woProblems.get(woId).add('Non-Confirmed line is not able to be Submitted: ' + wd.Name);
				}
			}
		}

		for (Id woId : linesToDiscount.keySet())
		{
			SVMXC__Service_Order__c wo = woMap.get(woId);
			List<SVMXC__Service_Order_Line__c> lines = linesToDiscount.get(woId);
			// Call to lookup / apply Contract Discount to each line (contains SOQL.. not loop safe)
			SMAX_PS_WorkOrderPricingService.applyContractDiscounts(wo, lines);

			for (SVMXC__Service_Order_Line__c wd : lines)
			{
				// Check if a 100% Contract Discount and if so skip "Priced" status..
				if (wd.SMAX_PS_ContractPercentDiscount__c == 100.00)
				{
					wd.SVMXC__Line_Status__c = 'Submitted';
					wd.SMAX_PS_SubmitTxnId__c = txnId;
					wdToUpdate.add(wd);
					woIdsWithLinesToSend.add(woId);
				}
				else
				{
					if (!woProblems.containsKey(woId))
						woProblems.put(woId, new List<String>());
					woProblems.get(woId).add('Non-Confirmed line is not able to be Submitted: ' + wd.Name);
				}
			}
		}

		if (!wdToUpdate.isEmpty())
			update wdToUpdate;

		// Send the appropriate Events..
		List<SMAX_PS_WorkOrder_Event__e> events = new List<SMAX_PS_WorkOrder_Event__e>();
		for (Id woId : woMap.keySet())
		{
			SVMXC__Service_Order__c wo = woMap.get(woId);
			Boolean anyLinesToSend = woIdsWithLinesToSend.contains(woId);
			List<String> problems = woProblems.get(woId);
			if (completeIds.contains(woId))
			{
				if (problems != null && !problems.isEmpty())
				{
					String errorMsg = 'For a Work Order to transition to "Work Complete", the following must be corrected: ' + problems;
					wo.SMAX_PS_Completion_Errors__c = errorMsg;
					wo.SVMXC__Order_Status__c = WORK_COMPLETE_ERROR;
					// SVMXCFG-943 - Redirect to "Work Complete - Material Follow Up" Status
					if (errorMsg.contains('Non-Consumable Location'))
					{
						wo.SVMXC__Order_Status__c = WORK_COMPLETE_MATERIAL_FOLLOW_UP;
					}
					// Allow "Submit All Lines" to run at least..
					submitIds.add(woId);
				}
				else if (anyLinesToSend)
				{
					wo.SVMXC__Order_Status__c = WORK_COMPLETE_PENDING;

					SMAX_PS_WorkOrder_Event__e iEvent = new SMAX_PS_WorkOrder_Event__e();
					iEvent.SMAX_PS_Action__c = 'SUBMIT-COMPLETE';
					iEvent.SMAX_PS_WorkOrderId__c = woId;
					iEvent.SMAX_PS_SubmitTxnId__c = txnId;
					events.add(iEvent);
				}
				else if (wo.SMAX_PS_SAP_SystemStatus__c != 'TECO')
				{
					SMAX_PS_WorkOrder_Event__e iEvent = new SMAX_PS_WorkOrder_Event__e();
					iEvent.SMAX_PS_Action__c = 'COMPLETE';
					iEvent.SMAX_PS_WorkOrderId__c = woId;
					events.add(iEvent);
				}
				else
				{
					// JIRA #391 - Reissue Billing Request (after Rejecting)
					if (SMAX_PS_WorkOrderManager.isBillable(wo))
					{
						SMAX_PS_WorkOrder_Event__e iEvent = new SMAX_PS_WorkOrder_Event__e();
						iEvent.SMAX_PS_Action__c = 'BILLING REQUEST';
						iEvent.SMAX_PS_WorkOrderId__c = wo.Id;
						events.add(iEvent);
					}
					else
					{
						// WHAT NOW.. do we go straight to Closed?!?
					}
				}
			}
			if (anyLinesToSend && submitIds.contains(woId))
			{
				SMAX_PS_WorkOrder_Event__e iEvent = new SMAX_PS_WorkOrder_Event__e();
				iEvent.SMAX_PS_Action__c = 'SUBMIT';
				iEvent.SMAX_PS_WorkOrderId__c = woId;
				iEvent.SMAX_PS_SubmitTxnId__c = txnId;
				events.add(iEvent);
			}
		}

		// SVMXCFG-648 Reusing this method to ensure only 1 Event is sent
		//SMAX_PS_PlatformEventUtility.publishEvents(events, 'SMAX_PS_WorkOrderId__c', 'SMAX_PS_Action__c');
		SMAX_PS_WorkOrderManager.sendWorkOrderEvents(events);
	}

	public class DebriefDetails
	{
		public Integer debriefLines { get; set; }
		public Integer faultCodeLines { get; set; }
		public Integer stuckLines { get; set; }
		public List<SVMXC__Service_Order_Line__c> allLines = new List<SVMXC__Service_Order_Line__c>();

		public DebriefDetails()
		{
			this.debriefLines = 0;
			this.faultCodeLines = 0;
			this.stuckLines = 0;
		}
	}

	// SVMXCFG-603: Cancel Work Order
	// SVMXCFG-553: added criteria to only send 'COMPLETE' events if External Id exists
	public static void cancelWorkOrders(List<SVMXC__Service_Order__c> woNewList, Map<Id, SVMXC__Service_Order__c> woOldMap)
	{
		if (!SMAX_PS_Utility.isActive('Work Order Cancel', 'Cancel a Work Order and send a TECO to SAP'))
			return;

		// Collect qualified Work Order Ids
		Map<Id, SVMXC__Service_Order__c> woMap = new Map<Id, SVMXC__Service_Order__c>();
		Set<Id> cancelledIds = new Set<Id>();
		for (SVMXC__Service_Order__c workOrder : woNewList)
		{
			SVMXC__Service_Order__c old = (woOldMap == null) ? null : woOldMap.get(workOrder.id);
			if ( old != null && old.SVMXC__Order_Status__c != workOrder.SVMXC__Order_Status__c && workOrder.SVMXC__Order_Status__c == CANCELED)
			{
				woMap.put(workOrder.Id, workOrder);
				cancelledIds.add(workOrder.Id);
			}
		}

		if (woMap.isEmpty())
			return;

		// Get Record Type Id for Usage Consumption 
		Id usageRecTypeId = SMAX_PS_Utility.getRecordType('SVMXC__Service_Order_Line__c', 'UsageConsumption').Id;

		System.debug('WO Cancel Starting');

		// Select the Work Detail lines which qualify for updation
		List<SVMXC__Service_Order_Line__c> lineList = new List<SVMXC__Service_Order_Line__c>([SELECT Id, Name, 
			SVMXC__Line_Status__c, SVMXC__Line_Type__c, SVMXC__Service_Order__c,
			SVMXC__Product__c, SMAX_PS_ContractPercentDiscount__c, SMAX_PS_IntegrationStatus__c
			FROM SVMXC__Service_Order_Line__c WHERE SVMXC__Service_Order__c in :woMap.keySet() 
			AND RecordTypeId = :usageRecTypeId AND SVMXC__Line_Status__c != 'Canceled' AND SVMXC__Line_Type__c != 'Fault Code']);

		Map<Id, List<SVMXC__Service_Order_Line__c>> lineMap = new Map<Id, List<SVMXC__Service_Order_Line__c>>();
		for (SVMXC__Service_Order_Line__c line : lineList)
		{
			if (!lineMap.containsKey(line.SVMXC__Service_Order__c))
				lineMap.put(line.SVMXC__Service_Order__c, new List<SVMXC__Service_Order_Line__c>());
			lineMap.get(line.SVMXC__Service_Order__c).add(line);
		}

		// Send the appropriate Events.. (or throw an error)
		Set<Id> whatIds = new Set<Id>();
		List<SMAX_PS_WorkOrder_Event__e> events = new List<SMAX_PS_WorkOrder_Event__e>();
		for (SVMXC__Service_Order__c wo : woMap.values())
		{
			List<SVMXC__Service_Order_Line__c> lines = lineMap.get(wo.Id);
			if (lines != null && lines.size() > 0)
			{
				List<String> lineNames = new List<String>();
				for (SVMXC__Service_Order_Line__c line : lines)
					lineNames.add(line.Name);
				wo.addError('Work Order cannot be Canceled because there are Non-Cancelled Work Detail lines: ' + lineNames);
			}
			else
			{
				if (wo.SMAX_PS_SAP_SystemStatus__c != 'TECO' && wo.SVMX_PS_External_Id__c != null)
				{
					SMAX_PS_WorkOrder_Event__e iEvent = new SMAX_PS_WorkOrder_Event__e();
					iEvent.SMAX_PS_Action__c = 'COMPLETE';
					iEvent.SMAX_PS_WorkOrderId__c = wo.Id;
					events.add(iEvent);
				}

				if (wo.SVMXC__Group_Member__c != null)
				{
					// SVMXCFG-648 Unassign...
					wo.SVMXC__Group_Member__c = null;
					wo.SVMXC__Service_Group__c = null;
					//wo.OwnerId = ???;
					whatIds.add(wo.Id);
				}
			}
		}

		if (!whatIds.isEmpty())
		{
			List<Event> eventsToDelete = [SELECT Id, Subject, WhatId FROM Event WHERE WhatId IN :whatIds];
			if (!eventsToDelete.isEmpty())	
			{
				Database.delete(eventsToDelete, false); // At least we tried..
			}
		}

		// SVMXCFG-648 Reusing this method to ensure only 1 Event is sent
		//SMAX_PS_PlatformEventUtility.publishEvents(events, 'SMAX_PS_WorkOrderId__c', 'SMAX_PS_Action__c');
		SMAX_PS_WorkOrderManager.sendWorkOrderEvents(events);
	}
}