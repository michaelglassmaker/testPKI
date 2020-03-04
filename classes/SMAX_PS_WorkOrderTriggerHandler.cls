public with sharing class SMAX_PS_WorkOrderTriggerHandler implements SMAX_PS_Utility.ITriggerHandler{
	public SMAX_PS_WorkOrderTriggerHandler() {
		
	}
	public void beforeInsert() 
	{
		List<SVMXC__Service_Order__c> newList = Trigger.new;

		// Added for Integration support.. Dec 2017
		SMAX_PS_WorkOrderManager.preventInvalidWorkOrders(newList);
		// Added for Integration support.. Dec 2017
		SMAX_PS_WorkOrderManager.copyRelatedData(newList, null);
		// SVMXINT-498: Scheduled Date logic for WO Load
		SMAX_PS_WorkOrderManager.syncScheduledDate(newList, null);
		// Added by Frank - Jan 10 2018
		SMAX_PS_WorkOrderManager.updateMappedValues(newList, null);
		// Added by Frank - Sep 27 2018 [SVMXCFG-777]
		SMAX_PS_WorkOrderManager.lookupTranslation(newList, null);
		// Refactored by Frank, for Complaints.. Mar 2018
		SMAX_PS_WorkOrderComplaints.updateManualComplaint(newList, null);
		// Added by Frank - Dec 22 2017
		SMAX_PS_WorkOrderComplaints.healthSafetyCheck(newList);
		//Added by Bill Convis - Oct 5 2017
		SMAX_PS_AutoEntitlement.performAutoEntitlementCheck(newList, null);
		// Added by Frank - WO Load Entitlement - Apr 3 2018
		SMAX_PS_AutoEntitlement.completeEntitlement(newList, null);
		SMAX_PS_AutoEntitlement.syncIsBillable(newList, null);
		// SVMXCFG-1000 - Service Estimate Assignment - Feb 21 2019
		SMAX_PS_AutoAssignment.autoAssignServiceEstimates(newList, null);
		// SVMXCFG-1109 - Reordered to AFTER autoAssignServiceEstimates
		SMAX_PS_WorkOrderManager.updateTechnicianDetails(newList, null);
	}

	public void afterInsert()
	{
		List<SVMXC__Service_Order__c> newList = Trigger.new;
		// Added by Veerendra - 22 Sep 2017
		SMAX_PS_WorkOrderManager.createWorkOrderEvents(newList, null);

		// ITSFDC-507 Perten - Extended Warranty on Instrument Parts
		SMAX_PS_ExtendedWarranty.createCoverage(newList);

		// ITSFDC-509 Auto-Create RMA for Depot WOs
		SMAX_PS_WorkOrderManager.autoCreateRMA(newList, null);

		// SVMXCFG-1108 Metrics & KPI
//		SMAX_PS_WorkOrderMetrics.countAssignments(newList, null);
//		SMAX_PS_WorkOrderMetrics.calculateMetricsOnRemote(newList, null);
//		SMAX_PS_WorkOrderMetrics.calculateMetricsOnTECO(newList, null);
//		SMAX_PS_WorkOrderMetrics.calculateMetricsOnCallback(newList);
	}

	public void beforeUpdate() 
	{
		List<SVMXC__Service_Order__c> newList = Trigger.new;
		Map<Id, SVMXC__Service_Order__c> oldMap = (Map<Id, SVMXC__Service_Order__c>) Trigger.oldMap;

		// Added by Frank - Aug 9 2018 [SVMXCFG-682]
		SMAX_PS_WorkOrderManager.copyRelatedData(newList, oldMap);
		// Added by Frank - Jan 10 2018
		SMAX_PS_WorkOrderManager.updateMappedValues(newList, oldMap);
		// ITSFDC-507 Extended Warranty and other Roll-ups
		SMAX_PS_WorkOrderManager.updateRollups(newList, oldMap);
		// Added by Frank - Sep 27 2018 [SVMXCFG-777]
		SMAX_PS_WorkOrderManager.lookupTranslation(newList, oldMap);
		// Refactored by Frank, for Complaints.. Mar 2018
		SMAX_PS_WorkOrderComplaints.updateManualComplaint(newList, oldMap);
		// Added by Veerendra - 22 Sep 2017
		SMAX_PS_WorkOrderManager.updateWorkOrderStatus(newList, oldMap);

		/* ENTITLEMENT LOGIC */
		//Added by Bill Convis - Oct 5 2017
		SMAX_PS_AutoEntitlement.performAutoEntitlementCheck(newList, oldMap);
		// Added by Frank - WO Load Entitlement - Apr 3 2018
		SMAX_PS_AutoEntitlement.completeEntitlement(newList, oldMap);
		SMAX_PS_AutoEntitlement.syncIsBillable(newList, oldMap);

		/* ASSIGNMENT LOGIC */
		// SVMXCFG-1103: Estimate Conversions
		SMAX_PS_AutoAssignment.convertedFromEstimate(newList, oldMap);
		// SVMXINT-493: Sync the Scheduled Date from the Scheduled Datetime
		SMAX_PS_WorkOrderManager.syncScheduledDate(newList, oldMap);
		//Added by Frank - Dev 7 2017
		SMAX_PS_AutoAssignment.confirmScheduling(newList, oldMap);
		// SVMXCFG-837 Unassign change back to "Open"
		SMAX_PS_WorkOrderManager.unassignWO(newList, oldMap);
		// Added by Frank - Nov 28 2017
		SMAX_PS_AutoAssignment.performAutoAssignmentCheck(newList, oldMap);
		// SVMXCFG-1000 - Service Estimate Assignment - Feb 21 2019
		SMAX_PS_AutoAssignment.autoAssignServiceEstimates(newList, oldMap);
		// ITSFDC-509 Auto-Assign Depot Owner Changes
		SMAX_PS_AutoAssignment.autoAssignOwnerChanges(newList, oldMap);
		// SVMXCFG-1109 - Reordered to AFTER autoAssignServiceEstimates
		SMAX_PS_WorkOrderManager.updateTechnicianDetails(newList, oldMap);
		// SVMXCFG-682 Added by Frank - Aug 21 2018
		SMAX_PS_AutoAssignment.finishAssignment(newList, oldMap);

		/* COMPLETE & EVENT LOGIC */
		// Added by Frank, for Regulatory Questions - Jan 16 2018
		SMAX_PS_WorkOrderComplaints.updateComplaintDetails(newList, oldMap);
		// Added by Frank, for Fault Codes - Dec 29 2017
		SMAX_PS_WorkOrderComplaints.validateComplaintAnswers(newList, oldMap);
		// SVMXINT-528-530 WO One-Click Complete - Swapping out calls..
			//SMAX_PS_WorkOrderManager.updateWorkDetailLineStatus(newList, oldMap);
			//SMAX_PS_WorkOrderManager.addWorkCompleteError(newList, oldMap);
			SMAX_PS_WorkOrderDebriefManager.submitCompleteAll(newList, oldMap);

		// SVMXCFG-603: Cancel Work Order
		SMAX_PS_WorkOrderDebriefManager.cancelWorkOrders(newList, oldMap);

		// Added by Frank - Dec 13 2017
		SMAX_PS_WorkOrderManager.forceWorkOrderEvents(newList);
	}

	public void afterUpdate()
	{
		List<SVMXC__Service_Order__c> newList = Trigger.new;
		Map<Id, SVMXC__Service_Order__c> oldMap = (Map<Id, SVMXC__Service_Order__c>) Trigger.oldMap;
		
		// Added by Veerendra - 22 Sep 2017
		SMAX_PS_WorkOrderManager.createWorkOrderEvents(newList, oldMap);
		// SVMXINT-502: Create Int Errors to detect duplicate processing
		SMAX_PS_WorkOrderManager.logDuplicateErrors(newList, oldMap);
		// ITSFDC-509 Auto-Create RMA for Depot WOs
		SMAX_PS_WorkOrderManager.autoCreateRMA(newList, oldMap);

		// SVMXCFG-1108 Metrics & KPI
//		SMAX_PS_WorkOrderMetrics.countAssignments(newList, oldMap);
//		SMAX_PS_WorkOrderMetrics.calculateMetricsOnRemote(newList, oldMap);
//		SMAX_PS_WorkOrderMetrics.calculateMetricsOnTECO(newList, oldMap);
//		SMAX_PS_WorkOrderMetrics.calculateMetricsOnInvoicing(newList, oldMap);
	}

	public void beforeDelete() {}
	public void afterDelete() 
	{
		//List<SVMXC__Service_Order__c> oldList = Trigger.old;
	}

	public void afterUndelete() 
	{
		//List<SVMXC__Service_Order__c> newList = Trigger.new;
	}   
}