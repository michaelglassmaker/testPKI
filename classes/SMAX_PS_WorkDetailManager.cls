/*
 *  Apex Class for Work Detail [SVMXC__Service_Order_Line__c] Business Logic.
 *  2017-09-21      Veerendra Moodbidri       Initial creation, for Work Detail Outbound Integration.
 *  1. Create Work Order Event when the Line is Submitted or Cancelled and update Integration to 'Pending.
 *  2. Before Update Work Detail Line to 'Confirmed' and Integration Status to 'Completed'.
 *  3. After Update Work Detail Line to 'Canceled' and Integration Status to 'Completed'.
 */

public with sharing class SMAX_PS_WorkDetailManager {

	private SMAX_PS_WorkDetailManager() {
	}

	public static void copyRelatedData(List<SVMXC__Service_Order_Line__c> detailList)
	{
		if (!SMAX_PS_Utility.isActive('Work Detail Copy Related Data', 'Copy Work Order fields when Work Details are created.'))
			return;

		Set<Id> woIds = new Set<Id>();
		for (SVMXC__Service_Order_Line__c wd : detailList)
		{
			woIds.add(wd.SVMXC__Service_Order__c);
		}

		Map<Id, SVMXC__Service_Order__c> woMap = new Map<Id, SVMXC__Service_Order__c>([SELECT Id, CurrencyIsoCode 
			FROM SVMXC__Service_Order__c WHERE Id IN :woIds]);
		for (SVMXC__Service_Order_Line__c wd : detailList)
		{
			SVMXC__Service_Order__c wo = woMap.get(wd.SVMXC__Service_Order__c);
			if (wo != null)
			{
				wd.CurrencyIsoCode = wo.CurrencyIsoCode;
			}
		}
	}

	public static void updateFieldValues(List<SVMXC__Service_Order_Line__c> detailList, Map<Id, SVMXC__Service_Order_Line__c> oldMap)
	{
		if (!SMAX_PS_Utility.isActive('Work Detail Update Field Values', 'Update Work Detail fields when Work Details are updated.'))
			return;

		for (SVMXC__Service_Order_Line__c wd : detailList)
		{
			// [SVMXCFG-436] Copy the Contract Discount to the OOTB Discount field
			wd.SVMXC__Discount__c = wd.SMAX_PS_ContractPercentDiscount__c;
			// [SVMXCFG-519] Round Labor and Travel to 1 decimal place
			if ((wd.SVMXC__Line_Type__c == 'Labor' || wd.SVMXC__Line_Type__c == 'Travel') && wd.SVMXC__Actual_Quantity2__c != null)
			{
				wd.SVMXC__Actual_Quantity2__c = wd.SVMXC__Actual_Quantity2__c.setScale(1, System.RoundingMode.DOWN);
			}

			// [ITSFDC-89] If Adjustment value, but no "Type", default to "Uplift"
			if (wd.SMAX_PS_ServiceAmountAdjustment__c != null && wd.SMAX_PS_ServiceAmountAdjustmentType__c == null)
			{
				wd.SMAX_PS_ServiceAmountAdjustmentType__c = 'Uplift';
			}
			if (wd.SMAX_PS_ServicePercentAdjustment__c != null && wd.SMAX_PS_ServicePercentAdjustmentType__c == null)
			{
				wd.SMAX_PS_ServicePercentAdjustmentType__c = 'Uplift';
			}
		}
	}

	public static void toggleIntegrationStatus(List<SVMXC__Service_Order_Line__c> wDetailNewList, Map<Id, SVMXC__Service_Order_Line__c> wDetailOldMap)
	{
		if (!SMAX_PS_Utility.isActive('Work Detail Toggle Int Status', 'Toggle Integration Status when Work Details are Submitted or Cancelled.'))
			return;

		// Update the Integration status in Work Detail
		if (!wDetailNewList.isEmpty()) {
			for (SVMXC__Service_Order_Line__c wd : wDetailNewList) {
				SVMXC__Service_Order_Line__c old = (wDetailOldMap == null) ? null : wDetailOldMap.get(wd.Id);
				if ( old != null && old.SVMXC__Line_Status__c != wd.SVMXC__Line_Status__c)
				{
					if (wd.SVMXC__Line_Status__c == 'Submitted') {
						wd.SMAX_PS_IntegrationStatus__c='Pending';
					}
					else if (wd.SVMXC__Line_Status__c == 'Canceled') {
						// SVMXINT-512: Work Detail: Only Cancel if Confirmed
						if (String.isNotBlank(wd.SMAX_PS_SAP_Confirmation__c)) {
							wd.SMAX_PS_IntegrationStatus__c='Pending';
						} else {
							wd.SMAX_PS_IntegrationStatus__c = null;
						}
					}
				} 
			}
		}
	}

	/**
	 *  DEPRECATED as part of One-Click Complete
	 */
	//public static void createWorkOrderEvent(List<SVMXC__Service_Order_Line__c> wDetailNewList, Map<Id, SVMXC__Service_Order_Line__c> wDetailOldMap)
	//{
	//	if (!SMAX_PS_Utility.isActive('Work Detail Events', 'Create Work Order Platform Events when Work Details are Submitted or Cancelled.'))
	//		return;

	//	List<SMAX_PS_WorkOrder_Event__e> events = new List<SMAX_PS_WorkOrder_Event__e>();
	//	Map<Id, String> eventMap = new Map<Id, String>();
	//	Set<Id> submittedWoIds = new Set<Id>();
	//	Set<Id> cancelledWoIds = new Set<Id>();

	//	// Collect qualified Work Order Ids for which Events have to be created
	//	if (!wDetailNewList.isEmpty()) {
	//		for (SVMXC__Service_Order_Line__c wd : wDetailNewList) {
	//			SVMXC__Service_Order_Line__c old = (wDetailOldMap == null) ? null : wDetailOldMap.get(wd.Id);
	//			// SVMXINT-512: Adding the Pending Check.. 
	//			if ( old != null && old.SVMXC__Line_Status__c != wd.SVMXC__Line_Status__c && wd.SMAX_PS_IntegrationStatus__c == 'Pending')
	//			{
	//				if (wd.SVMXC__Line_Status__c == 'Submitted') {
	//					submittedWoIds.add(wd.SVMXC__Service_Order__c);
	//				}
	//				else if (wd.SVMXC__Line_Status__c == 'Canceled') {
	//					cancelledWoIds.add(wd.SVMXC__Service_Order__c);
	//				}
	//			}
	//		}
	//	}

	//	// Publish the Event(s)
	//	if (!submittedWoIds.isEmpty()) {
	//		for (Id wo : submittedWoIds) {
	//			SMAX_PS_WorkOrder_Event__e iEvent = new SMAX_PS_WorkOrder_Event__e();
	//			iEvent.SMAX_PS_Action__c = 'SUBMIT';
	//			iEvent.SMAX_PS_WorkOrderId__c = wo;
	//			events.add(iEvent);
	//		}
	//	}
	//	if (!cancelledWoIds.isEmpty()) {
	//		for (Id wo : cancelledWoIds) {
	//			SMAX_PS_WorkOrder_Event__e iEvent = new SMAX_PS_WorkOrder_Event__e();
	//			iEvent.SMAX_PS_Action__c = 'CANCEL';
	//			iEvent.SMAX_PS_WorkOrderId__c = wo;
	//			events.add(iEvent);
	//		}
	//	}

		//SMAX_PS_PlatformEventUtility.publishEvents(events, 'SMAX_PS_WorkOrderId__c', 'SMAX_PS_Action__c');
	//}

	/**
	 *  Replaces createWorkOrderEvent(...), removing the submit logic, and adding txnId
	 *  Should be called from the before update (but after toggleIntegrationStatus(...))
	 */
	public static void cancelLines(List<SVMXC__Service_Order_Line__c> wDetailNewList, Map<Id, SVMXC__Service_Order_Line__c> wDetailOldMap)
	{
		if (!SMAX_PS_Utility.isActive('Work Detail Cancel Lines', 'Create Work Order Platform Events when Work Details are Cancelled.'))
			return;

		Set<Id> cancelledWoIds = new Set<Id>();
		String txnId = String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));

		// Collect qualified Work Order Ids for which Events have to be created
		for (SVMXC__Service_Order_Line__c wd : wDetailNewList) {
			SVMXC__Service_Order_Line__c old = (wDetailOldMap == null) ? null : wDetailOldMap.get(wd.Id);
			// SVMXINT-512: Adding the Pending Check.. 
			if ( old != null && old.SVMXC__Line_Status__c != wd.SVMXC__Line_Status__c && wd.SMAX_PS_IntegrationStatus__c == 'Pending')
			{
				if (wd.SVMXC__Line_Status__c == 'Canceled') {
					wd.SMAX_PS_SubmitTxnId__c = txnId;
					cancelledWoIds.add(wd.SVMXC__Service_Order__c);
				}
			}
		}

		if (cancelledWoIds.isEmpty())
			return;

		// Publish the Event(s)
		List<SMAX_PS_WorkOrder_Event__e> events = new List<SMAX_PS_WorkOrder_Event__e>();
		for (Id woId : cancelledWoIds) {
			SMAX_PS_WorkOrder_Event__e iEvent = new SMAX_PS_WorkOrder_Event__e();
			iEvent.SMAX_PS_Action__c = 'CANCEL';
			iEvent.SMAX_PS_SubmitTxnId__c = txnId;
			iEvent.SMAX_PS_WorkOrderId__c = woId;
			events.add(iEvent);
		}

        SMAX_PS_PlatformEventUtility.publishEvents(events, 'SMAX_PS_WorkOrderId__c', 'SMAX_PS_Action__c');
	}

	private static Set<String> PRE_CONFIRMED = new Set<String> { 'Open', 'Submitted', 'Priced' };

	public static void updateDetailLineAndIntegrationStatus(List<SVMXC__Service_Order_Line__c> wDetailNewList, Map<Id, SVMXC__Service_Order_Line__c> wDetailOldMap)
	{
		if (!SMAX_PS_Utility.isActive('Update Detail And Integration Status', 'Update the Line Status and the Integration Status in Work Detail when the SAP Confirmation and the Cancellation Number are changed.'))
			return;

		// Update Work Detail Line and Integration Status
		if (!wDetailNewList.isEmpty()) {
			for (SVMXC__Service_Order_Line__c wd : wDetailNewList) {
				SVMXC__Service_Order_Line__c old = (wDetailOldMap == null) ? null : wDetailOldMap.get(wd.id);

				// SVMXCFG-494: PREVENT lost SAP Confirmation numbers
				if ( old != null && String.isBlank(wd.SMAX_PS_SAP_Confirmation__c) && String.isNotBlank(old.SMAX_PS_SAP_Confirmation__c))
				{
					wd.SMAX_PS_SAP_Confirmation__c = old.SMAX_PS_SAP_Confirmation__c;
					wd.SVMXC__Line_Status__c='Confirmed';
					wd.SMAX_PS_IntegrationStatus__c='Completed';
				}
				// SVMXCFG-530: Work Detail: Prevent Status Rollback
				if ( old != null && old.SVMXC__Line_Status__c == 'Confirmed' && PRE_CONFIRMED.contains(wd.SVMXC__Line_Status__c))
				{
					wd.SVMXC__Line_Status__c='Confirmed';
				}
				if ( old != null && wd.SMAX_PS_SAP_Confirmation__c != null && wd.SMAX_PS_SAP_Confirmation__c != old.SMAX_PS_SAP_Confirmation__c ) 
				{
					wd.SVMXC__Line_Status__c='Confirmed';
					wd.SMAX_PS_IntegrationStatus__c='Completed';
				}
				if ( old != null && wd.SVMXC__Line_Status__c == 'Confirmed' && wd.SVMXC__Line_Status__c != old.SVMXC__Line_Status__c ) 
				{
					wd.SMAX_PS_IntegrationStatus__c='Completed';
				}
				if ( old != null && wd.SMAX_PS_CancellationNumber__c != null && wd.SMAX_PS_CancellationNumber__c != old.SMAX_PS_CancellationNumber__c ) 
				{
					wd.SVMXC__Line_Status__c='Canceled';
					wd.SMAX_PS_IntegrationStatus__c='Completed';
				}
			}
		}
	}

	public static void updateUnitOfMeasureCodes(List<SVMXC__Service_Order_Line__c> detailList, Map<Id, SVMXC__Service_Order_Line__c> oldMap)
	{
		if (!SMAX_PS_Utility.isActive('Update Unit Of Measure Codes', 'Update the Unit of Measurement codes.'))
			return;

		// Based on this Checkbox.. SMAX_PS_Use_Product_Sales_UOM__c
		// Update this field:  SMAX_PS_UnitOfMeasure__c
		// And this field:  SMAX_PS_UOM_Code__c
		List<SVMXC__Service_Order_Line__c> detailsToUpdate = new List<SVMXC__Service_Order_Line__c>();
		Set<Id> woIds = new Set<Id>();
		Set<Id> productIds = new Set<Id>();
		for (SVMXC__Service_Order_Line__c detail : detailList)
		{
			SVMXC__Service_Order_Line__c old = (oldMap == null) ? null : oldMap.get(detail.Id);
			if (detail.SMAX_PS_UnitOfMeasure__c == null || detail.SMAX_PS_UOM_Code__c == null
				|| (old != null && (detail.SMAX_PS_Use_Product_Sales_UOM__c != old.SMAX_PS_Use_Product_Sales_UOM__c
					|| detail.SVMXC__Product__c != old.SVMXC__Product__c)))
			{
				detailsToUpdate.add(detail);
				woIds.add(detail.SVMXC__Service_Order__c);
				productIds.add(detail.SVMXC__Product__c);
			}
		}

		if (detailsToUpdate.isEmpty())
			return;

		// ProductSales below is based on SalesOrg from Location... SMAX_PS_SalesOrg__c
		Set<String> salesOrgs = new Set<String>();
		Map<Id, SVMXC__Service_Order__c> woMap = new Map<Id, SVMXC__Service_Order__c>(
			[SELECT Id, SVMXC__Site__c, SVMXC__Site__r.SMAX_PS_SalesOrg__c FROM SVMXC__Service_Order__c WHERE Id IN :woIds]);
		for (SVMXC__Service_Order__c wo : woMap.values())
		{
			if (wo.SVMXC__Site__c != null && wo.SVMXC__Site__r.SMAX_PS_SalesOrg__c != null)
			{   
				salesOrgs.add(wo.SVMXC__Site__r.SMAX_PS_SalesOrg__c);
			}
		}

		Map<Id, Product2> productMap = new Map<Id, Product2>(
			[SELECT Id, ProductCode, QuantityUnitOfMeasure, PKI_Qty_UOM_Code__c,
				(SELECT Id, SMAX_PS_ExternalID__c, SMAX_PS_SalesOrg__c, SMAX_PS_SalesUnit__c, SMAX_PS_Sales_Unit_Code__c 
					FROM Product_Sales__r WHERE SMAX_PS_SalesOrg__c IN :salesOrgs)
				FROM Product2 WHERE Id IN :productIds]);

		// ... from either Product: (if false)   QuantityUnitOfMeasure , PKI_Qty_UOM_Code__c
		// OR from the SalesProduct [SMAX_PS_ProductSales__c]: (if true)  SMAX_PS_SalesUnit__c , SMAX_PS_Sales_Unit_Code__c
		for (SVMXC__Service_Order_Line__c detail : detailsToUpdate)
		{
			Product2 prod = productMap.get(detail.SVMXC__Product__c);
			SVMXC__Service_Order__c wo = woMap.get(detail.SVMXC__Service_Order__c);
			String salesOrg = wo.SVMXC__Site__r.SMAX_PS_SalesOrg__c;
			SMAX_PS_WorkDetailManager.updateUnitOfMeasureCodes(detail, salesOrg, prod);
		}
	}

	public static void updateUnitOfMeasureCodes(SVMXC__Service_Order_Line__c detail, String salesOrg, Product2 prod)
	{
		if (!SMAX_PS_Utility.isActive('Update Unit Of Measure Codes', 'Update Work detail Qty UOM from the Product.'))
			return;

		if (prod == null)
			return;
			
		if (detail.SMAX_PS_Use_Product_Sales_UOM__c == TRUE)
		{
			SMAX_PS_ProductSales__c productSales = null;
			for (SMAX_PS_ProductSales__c sales : prod.Product_Sales__r)
			{
				if (sales.SMAX_PS_SalesOrg__c == salesOrg)
				{
					productSales = sales;
					break;
				}
			}

			if (productSales == null)
			{
				String errorMsg = 'ProductSales for Product: ' + prod.ProductCode + ' and SalesOrg: ' 
					+ salesOrg + ' not found.  Cannot use "Sales UOM".';
				System.debug(errorMsg);
				//detail.addError(errorMsg);
				detail.SMAX_PS_Use_Product_Sales_UOM__c = FALSE;
			}
			else if (productSales.SMAX_PS_SalesUnit__c == null || productSales.SMAX_PS_Sales_Unit_Code__c == null)
			{
				String errorMsg = 'ProductSales: ' + productSales.SMAX_PS_ExternalID__c 
					+ ' does not have "Sales UOM" values.  Cannot use "Sales UOM".';
				System.debug(errorMsg);
				//detail.addError(errorMsg);
				detail.SMAX_PS_Use_Product_Sales_UOM__c = FALSE;
			}
			else
			{
				detail.SMAX_PS_UnitOfMeasure__c = productSales.SMAX_PS_SalesUnit__c;
				detail.SMAX_PS_UOM_Code__c = productSales.SMAX_PS_Sales_Unit_Code__c;
			}
		}

		if (detail.SMAX_PS_Use_Product_Sales_UOM__c == FALSE)
		{
			detail.SMAX_PS_UnitOfMeasure__c = prod.QuantityUnitOfMeasure;
			detail.SMAX_PS_UOM_Code__c = prod.PKI_Qty_UOM_Code__c;
		}
	}

	/**
	 * Check if the newly created or updated WO Detail is a Fault code.  If so...
	 * 1) fill in the field: SMAX_PS_Fault_Code_Complaint_Required__c based on if any of the related Fault Codes have Complaint Required values of 1.
	 * 2) fill in the corresponding Picklists with their Description/Code values (temporary)
	*/
	public static void updateFaultCodes(List<SVMXC__Service_Order_Line__c> detailList, Map<Id, SVMXC__Service_Order_Line__c> oldMap)
	{
		if (!SMAX_PS_Utility.isActive('Update Fault Codes', 'Update the Fault Code Complaint Required field in Work Detail from the Fault Codes object.'))
			return;

		List<SVMXC__Service_Order_Line__c> faultCodeLines = new List<SVMXC__Service_Order_Line__c>();
		Set<Id> faultCodeIds = new Set<Id>();
		for (SVMXC__Service_Order_Line__c detail : detailList)
		{
			SVMXC__Service_Order_Line__c old = (oldMap == null) ? null : oldMap.get(detail.Id);
			if (detail.SVMXC__Line_Type__c != 'Fault Code')
				continue;

			faultCodeLines.add(detail);
			if (detail.SMAX_PS_Fault_Code__c != null)
			{
				faultCodeIds.add(detail.SMAX_PS_Fault_Code__c);
			}
			if (detail.SMAX_PS_ActionFaultCode__c != null)// && (old == null || detail.SMAX_PS_ActionFaultCode__c != old.SMAX_PS_ActionFaultCode__c))
			{
				faultCodeIds.add(detail.SMAX_PS_ActionFaultCode__c);
			}
			if (detail.SMAX_PS_InstallationFaultCode__c != null)// && (old == null || detail.SMAX_PS_InstallationFaultCode__c != old.SMAX_PS_InstallationFaultCode__c))
			{
				faultCodeIds.add(detail.SMAX_PS_InstallationFaultCode__c);
			}
			if (detail.SMAX_PS_CompletionFaultCode__c != null)// && (old == null || detail.SMAX_PS_CompletionFaultCode__c != old.SMAX_PS_CompletionFaultCode__c))
			{
				faultCodeIds.add(detail.SMAX_PS_CompletionFaultCode__c);
			}
		}

		if (faultCodeLines.isEmpty())
			return;

		Map<Id, SMAX_PS_Fault_Code__c> faultCodeMap = new Map<Id, SMAX_PS_Fault_Code__c>(
			[SELECT Id, Name, SMAX_PS_Code_Description__c, SMAX_PS_Code__c, SMAX_PS_Complaint_Required__c 
				FROM SMAX_PS_Fault_Code__c WHERE Id IN :faultCodeIds]);
		for (SVMXC__Service_Order_Line__c detail : faultCodeLines)
		{
			Decimal complaintRequired = 0;
			if (detail.SMAX_PS_Fault_Code__c != null && faultCodeMap.containsKey(detail.SMAX_PS_Fault_Code__c))
			{
				SMAX_PS_Fault_Code__c fc = faultCodeMap.get(detail.SMAX_PS_Fault_Code__c);
				complaintRequired += (fc.SMAX_PS_Complaint_Required__c == null) ? 0 : fc.SMAX_PS_Complaint_Required__c;
			}
			if (detail.SMAX_PS_ActionFaultCode__c != null && faultCodeMap.containsKey(detail.SMAX_PS_ActionFaultCode__c))
			{
				SMAX_PS_Fault_Code__c fc = faultCodeMap.get(detail.SMAX_PS_ActionFaultCode__c);
				detail.SMAX_PS_Fault_Code_Action__c = fc.SMAX_PS_Code_Description__c + '~' + fc.SMAX_PS_Code__c;
				complaintRequired += (fc.SMAX_PS_Complaint_Required__c == null) ? 0 : fc.SMAX_PS_Complaint_Required__c;
			}
			if (detail.SMAX_PS_InstallationFaultCode__c != null && faultCodeMap.containsKey(detail.SMAX_PS_InstallationFaultCode__c))
			{
				SMAX_PS_Fault_Code__c fc = faultCodeMap.get(detail.SMAX_PS_InstallationFaultCode__c);
				detail.SMAX_PS_Installation_Code__c = fc.SMAX_PS_Code__c + ' ~ ' + fc.SMAX_PS_Code_Description__c;
				complaintRequired += (fc.SMAX_PS_Complaint_Required__c == null) ? 0 : fc.SMAX_PS_Complaint_Required__c;
			}
			if (detail.SMAX_PS_CompletionFaultCode__c != null && faultCodeMap.containsKey(detail.SMAX_PS_CompletionFaultCode__c))
			{
				SMAX_PS_Fault_Code__c fc = faultCodeMap.get(detail.SMAX_PS_CompletionFaultCode__c);
				detail.SMAX_PS_Completion_Code__c = fc.SMAX_PS_Code__c + ' ~ ' + fc.SMAX_PS_Code_Description__c;
				complaintRequired += (fc.SMAX_PS_Complaint_Required__c == null) ? 0 : fc.SMAX_PS_Complaint_Required__c;
			}
			detail.SMAX_PS_Fault_Code_Complaint_Required__c = complaintRequired;
		}
	}

	public static void updateTechOnDebriefLine(List<SVMXC__Service_Order_Line__c> newList, Map<Id, SVMXC__Service_Order_Line__c> oldMap)
	{
		// call to service register
		if (!SMAX_PS_Utility.isActive('updateTechOnDebriefLine','Places the ID of Technician working on a detail into the Technician field')) { return; }
		
		List<SVMXC__Service_Group_Members__c> debriefTechs = 
			[SELECT Id, Name FROM SVMXC__Service_Group_Members__c WHERE SVMXC__Salesforce_User__c = :userinfo.getUserId()];  
		
		if (debriefTechs.size() > 0 )
		{
			Id usageRecTypeId = SMAX_PS_Utility.getRecordType('SVMXC__Service_Order_Line__c', 'UsageConsumption').Id;
			for (SVMXC__Service_Order_Line__c wd : newList) 
			{
				if (wd.SVMXC__Group_Member__c == null && wd.RecordTypeId == usageRecTypeId && debriefTechs[0] != null) 
				{
					wd.SVMXC__Group_Member__c = debriefTechs[0].Id;
				}
			}
		}
	}

	/**
	 *	SVMXINT-502: Create Int Errors to detect duplicate processing
	 *	Should be called from WorkDetail After Update trigger
	 */
	public static void logDuplicateErrors(List<SVMXC__Service_Order_Line__c> wdList, Map<Id, SVMXC__Service_Order_Line__c> oldMap)
	{
		if (!SMAX_PS_Utility.isActive('Work Detail Dulicate Errors', 'Create Integration Errors when SAP Confirmation Numbers are changed.'))
			return;

		List<SMAX_PS_IntegrationError__c> errorList = new List<SMAX_PS_IntegrationError__c>();
		for (SVMXC__Service_Order_Line__c detail : wdList)
		{
			SVMXC__Service_Order_Line__c old = (oldMap == null) ? null : oldMap.get(detail.Id);
			if (old == null)
				continue;

			if (old.SMAX_PS_SAP_Confirmation__c != null && detail.SMAX_PS_SAP_Confirmation__c != old.SMAX_PS_SAP_Confirmation__c)
			{
				SMAX_PS_IntegrationError__c ie = new SMAX_PS_IntegrationError__c();
				ie.SMAX_PS_RelatedElementType__c = 'WorkDetailId';
				ie.SMAX_PS_RelatedElementIdentifier__c = detail.Id;
				ie.SMAX_PS_ErrorMessage__c = 'DUPLICATE PROCESSING: Work Detail posted as multiple SAP Confirmation Numbers: '
					+ old.SMAX_PS_SAP_Confirmation__c + ', ' + detail.SMAX_PS_SAP_Confirmation__c;
				errorList.add(ie);
			}
			if (old.SMAX_PS_CancellationNumber__c != null && detail.SMAX_PS_CancellationNumber__c != old.SMAX_PS_CancellationNumber__c)
			{
				SMAX_PS_IntegrationError__c ie = new SMAX_PS_IntegrationError__c();
				ie.SMAX_PS_RelatedElementType__c = 'WorkDetailId';
				ie.SMAX_PS_RelatedElementIdentifier__c = detail.Id;
				ie.SMAX_PS_ErrorMessage__c = 'DUPLICATE PROCESSING: Work Order posted as multiple SAP Cancellation Numbers: '
					+ old.SMAX_PS_CancellationNumber__c + ', ' + detail.SMAX_PS_CancellationNumber__c;
				errorList.add(ie);
			}
		}

		if (!errorList.isEmpty())
			insert errorList;
	}
	//SVMXCFG-690 copy first 40 chars of Work Description to Work Summary
	public static void addWorkSummary(List<SVMXC__Service_Order_Line__c> wdList)
	{
		for(SVMXC__Service_Order_Line__c wd:wdList)
		{	
			if (wd.SVMXC__Work_Description__c != null)
			{
				String wdSum = (wd.SVMXC__Work_Description__c.length() > 40) ? 
					wd.SVMXC__Work_Description__c.substring(0,40) : wd.SVMXC__Work_Description__c;
				wd.SMAX_PS_WorkSummary__c = wdSum;

				// SVMXCFG-1054 - Populate the "Concat Part Work Description"
				//wd.SMAX_PS_Concat_Part_Work_Description__c = wd.SMAX_PS_Material_Part_Description__c + '<br/>' + wd.SVMXC__Work_Description__c;
			}
		}
	}

	// ITSFDC-509 Lookup and copy data from ProductPlant for Parts lines
	// Should be called from the BEFORE-INSERT/UPDATE Triggers
	public static void lookupProductPlant(List<SVMXC__Service_Order_Line__c> wdList, Map<Id, SVMXC__Service_Order_Line__c> oldMap)
	{
		if (!SMAX_PS_Utility.isActive('Work Detail Product Plant', 'Lookup the Product Plant for Parts lines.'))
			return;

		Set<Id> woIds = new Set<Id>();
		Set<Id> prodIds = new Set<Id>();
		List<SVMXC__Service_Order_Line__c> wdToUpdate = new List<SVMXC__Service_Order_Line__c>();
		for (SVMXC__Service_Order_Line__c wd : wdList)
		{
			SVMXC__Service_Order_Line__c old = (oldMap == null) ? null : oldMap.get(wd.Id);
			if (wd.SVMXC__Line_Type__c == 'Parts' && wd.SVMXC__Product__c != null
				&& (old == null || old.SVMXC__Product__c != wd.SVMXC__Product__c))
			{
				woIds.add(wd.SVMXC__Service_Order__c);
				prodIds.add(wd.SVMXC__Product__c);
				wdToUpdate.add(wd);
			}
		}

		if (wdToUpdate.isEmpty())
		{
			return;
		}

		Set<String> plants = new Set<String>();
		Map<Id, SVMXC__Service_Order__c> woMap = new Map<Id, SVMXC__Service_Order__c>([SELECT Id, Name,
				SVMXC__Site__c, SVMXC__Site__r.SMAX_PS_MaintenancePlant__c, BD_Any_Parts_Eligible_for_Return__c
			FROM SVMXC__Service_Order__c WHERE Id IN :woIds]);
		for (SVMXC__Service_Order__c wo : woMap.values())
		{
			if (wo.SVMXC__Site__c != null && wo.SVMXC__Site__r.SMAX_PS_MaintenancePlant__c != null)
			{
				plants.add(wo.SVMXC__Site__r.SMAX_PS_MaintenancePlant__c);
			}
		}

		if (plants.isEmpty())
		{
			return;
		}

		List<SMAX_PS_ProductPlant__c> allProductPlants = [SELECT Id, Name, SMAX_PS_Product__c, SMAX_PS_Plant__c,
				BD_Return_Part__c, BD_Return_Part_Number__c, BD_Credit_Relevant_Part__c
			FROM SMAX_PS_ProductPlant__c WHERE SMAX_PS_Product__c IN :prodIds AND SMAX_PS_Plant__c IN :plants];
		Map<String, SMAX_PS_ProductPlant__c> ppMap = new Map<String, SMAX_PS_ProductPlant__c>();
		for (SMAX_PS_ProductPlant__c pp : allProductPlants)
		{
			String key = pp.SMAX_PS_Product__c + '-' + pp.SMAX_PS_Plant__c;
			ppMap.put(key, pp);
		}

		Map<Id, SVMXC__Service_Order__c> woUpdateMap = new Map<Id, SVMXC__Service_Order__c>();
		for (SVMXC__Service_Order_Line__c wd: wdToUpdate)
		{
			SVMXC__Service_Order__c wo = woMap.get(wd.SVMXC__Service_Order__c);
			String plant = (wo != null && wo.SVMXC__Site__c != null) ? wo.SVMXC__Site__r.SMAX_PS_MaintenancePlant__c : null;
			String key = wd.SVMXC__Product__c + '-' + plant;
			SMAX_PS_ProductPlant__c pp = ppMap.get(key);
			if (pp != null)
			{
				wd.BD_Product_Plant__c = pp.Id;
				wd.BD_Eligible_for_Return__c = (pp.BD_Return_Part__c != null || pp.BD_Return_Part_Number__c != null);
				wd.BD_Return_Part_Number__c = pp.BD_Return_Part_Number__c;
				wd.SVMX_PS_VS_Return_Part__c = pp.BD_Return_Part__c;

				// Update the WO also...
				Boolean newValue = wo.BD_Any_Parts_Eligible_for_Return__c || wd.BD_Eligible_for_Return__c;
				if (newValue != wo.BD_Any_Parts_Eligible_for_Return__c)
				{
					wo.BD_Any_Parts_Eligible_for_Return__c = newValue;
					woUpdateMap.put(wo.Id, wo);
				}
			}
		}

		if (!woUpdateMap.isEmpty())
		{
			// NOTE: might need to move this to a future call IF problematic
			update woUpdateMap.values();
		}
	}

}