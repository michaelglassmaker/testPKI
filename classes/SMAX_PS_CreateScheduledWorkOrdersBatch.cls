/* 
 *  Schedulable Batch class for Creating Scheduled Work Orders
 *  2017-09-18		Bill Convis		Initial creation, for Batch Creation of WO via custom PM Schedule.
 *  2017-12-05      Frank VanLoon   Refactoring, fine-tuning.
 *  2018-06-18		Frank VanLoon	Updated for Phase 1.0: SVMXCFG-604, SVMXCFG-605
*/
global class SMAX_PS_CreateScheduledWorkOrdersBatch implements Database.Batchable<sobject> , Schedulable {

	global String CONTRACT_ITEM_ID;
	global String PARENT_CONTRACT_ID;
	global Date START_DATE;
	global Date END_DATE;
	//global Integer NUM_MONTHS_OUT;
	global Integer NUM_DAYS_OUT;
	global Set<String> SALES_ORGS;
	global Boolean IS_ENTERPRISE;

	public SMAX_PS_CreateScheduledWorkOrdersBatch() {}
	public SMAX_PS_CreateScheduledWorkOrdersBatch(String contractItemId, String parentContractId, Integer numDaysOut) 
	{
		this.CONTRACT_ITEM_ID = contractItemId;
		this.PARENT_CONTRACT_ID = parentContractId;
		this.NUM_DAYS_OUT = numDaysOut;
	}

	public SMAX_PS_CreateScheduledWorkOrdersBatch(Date startDate, Integer numDaysOut, Set<String> salesOrgs, Boolean isEnterprise)
	{
		this.START_DATE = startDate;
		this.NUM_DAYS_OUT = numDaysOut;
		this.SALES_ORGS = salesOrgs;
		this.IS_ENTERPRISE = isEnterprise;
	}

	/** 
		Schedulable methods 
	**/

	global void execute(SchedulableContext sc) 
	{
		SMAX_PS_CreateScheduledWorkOrdersBatch b = new SMAX_PS_CreateScheduledWorkOrdersBatch(this.START_DATE, this.NUM_DAYS_OUT, this.SALES_ORGS, this.IS_ENTERPRISE);
		database.executeBatch(b, 1);
	}

	/** 
		Batchable methods 
	**/

	global Database.QueryLocator start(Database.BatchableContext BC) 
	{
		// SVMXCFG-604: Scheduled WO Batch Job - Monthly
		//Integer numMonths = (NUM_MONTHS_OUT == null) ? 2 : NUM_MONTHS_OUT;
		//END_DATE = System.today().addMonths(numMonths+1).toStartOfMonth();

		// SVMXCFG-701 Revert to Num Days
		Integer numDays = (NUM_DAYS_OUT == null) ? 60 : NUM_DAYS_OUT;
		END_DATE = System.today().addDays(numDays);

		String query = 'SELECT Id, Name, SMAX_PS_PlannedDate__c, '
			+ 'SMAX_PS_ContractItem__c, SMAX_PS_ContractItem__r.SVMX_PS_Parent_Contract__c, '
			+ 'SMAX_PS_ContractItem__r.SVMX_PS_Parent_Contract__r.SVMXC__Contact__c, '
			+ 'SMAX_PS_ContractItem__r.SVMX_PS_Parent_Contract__r.SMAX_PS_SalesOrg__c, '
			+ 'SMAX_PS_ContractItem__r.SVMX_PS_Parent_Contract__r.SMAX_PS_PONumber__c, '
			+ 'SMAX_PS_ContractItem__r.SVMX_PS_Parent_Contract__r.SVMXC__Active__c, '
			+ 'SMAX_PS_ContractItem__r.SMAX_PS_SLA_Terms_Notes__c, '
			+ 'SMAX_PS_ContractItem__r.SMAX_PS_Is_Warranty__c, '
			+ 'SMAX_PS_ContractItem__r.SMAX_PS_Is_Enterprise__c, '
			+ 'SMAX_PS_Entitlement__c, SMAX_PS_Entitlement__r.SMAX_PS_EntitlementTypeName__c, '
			+ 'SMAX_PS_Entitlement__r.SMAX_PS_EntitlementType__c, '
			+ 'SMAX_PS_Entitlement__r.SVMXC__Labor_Discount_Covered__c, '
			+ 'SMAX_PS_Entitlement__r.SVMXC__Travel_Discount_Covered__c, '
			+ 'SMAX_PS_Entitlement__r.SVMXC__Parts_Discount_Covered__c, '
			+ 'SMAX_PS_Entitlement__r.SMAX_PS_ServicePartsDiscountCovered__c, '
			+ 'SMAX_PS_Entitlement__r.SMAX_PS_ConsumableDiscountCovered__c, '
			+ 'SMAX_PS_CoveredProduct__c, SMAX_PS_CoveredProduct__r.SVMXC__Installed_Product__c, '
			+ 'SMAX_PS_CoveredProduct__r.SVMXC__Installed_Product__r.SVMXC__Product__c, '
			+ 'SMAX_PS_CoveredProduct__r.SVMXC__Installed_Product__r.SVMXC__Site__c, '
			+ 'SMAX_PS_CoveredProduct__r.SVMXC__Installed_Product__r.SVMXC__Site__r.SVMXC__Account__c, '
			+ 'SMAX_PS_CoveredProduct__r.SVMXC__Installed_Product__r.SVMXC__Site__r.SMAX_PS_ShipTo__c, '
			+ 'SMAX_PS_CoveredProduct__r.SVMXC__Installed_Product__r.SVMXC__Site__r.SMAX_PS_BillTo__c, '
			+ 'SMAX_PS_CoveredProduct__r.SVMXC__Installed_Product__r.SVMXC__Site__r.SMAX_PS_Payer__c, '
			//+ 'SMAX_PS_CoveredProduct__r.SVMXC__Installed_Product__r.SVMXC__Site__r.SMAX_PS_SalesOrg__c, '
			+ 'SMAX_PS_CoveredProduct__r.SVMXC__Installed_Product__r.SVMXC__Contact__c, '
			+ 'SMAX_PS_CoveredProduct__r.SVMXC__Installed_Product__r.SMAX_PS_Technical_ID_Number__c, '
			+ 'SMAX_PS_CoveredProduct__r.SVMXC__Installed_Product__r.SMAX_PS_Building__c, '
			+ 'SMAX_PS_CoveredProduct__r.SVMXC__Installed_Product__r.SMAX_PS_Room__c '
		+ 'FROM SMAX_PS_EntitlementDate__c WHERE SMAX_PS_ServiceOrderNumber__c = null'
			+ ' AND SMAX_PS_SAP_Notification_ID__c = null'
			+ ' AND SMAX_PS_WorkOrder__c = null'
			+ ' AND SMAX_PS_PlannedDate__c < :END_DATE'
			+ ' AND SMAX_PS_IsDeleted__c = false';

		if (START_DATE != null)
		{
			query += ' AND SMAX_PS_PlannedDate__c >= :START_DATE';
		}
		// SVMXCFG-605: Batch Jobs - i18n Parameters
		if (SALES_ORGS != null && !SALES_ORGS.isEmpty())
		{
			//query += ' AND SMAX_PS_CoveredProduct__r.SVMXC__Installed_Product__r.SVMXC__Site__r.SMAX_PS_SalesOrg__c IN :SALES_ORGS';
			query += ' AND SMAX_PS_ContractItem__r.SVMX_PS_Parent_Contract__r.SMAX_PS_SalesOrg__c IN :SALES_ORGS';
		}
		// SVMXCFG-701 Add "Is Enterprise" parameter
		if (IS_ENTERPRISE != null)
		{
			query += ' AND SMAX_PS_ContractItem__r.SMAX_PS_Is_Enterprise__c = :IS_ENTERPRISE';
		}
		if (PARENT_CONTRACT_ID != null)
		{
			query += ' AND SMAX_PS_ContractItem__r.SVMX_PS_Parent_Contract__c = :PARENT_CONTRACT_ID';
		}
		if (CONTRACT_ITEM_ID != null)
		{
			query += ' AND SMAX_PS_ContractItem__c = :CONTRACT_ITEM_ID';
		}
		System.debug('SCHEDULED WO QUERY = ' + query);
		System.debug('SCHEDULED WO QUERY VALUES = ' + this);

		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<SMAX_PS_EntitlementDate__c> entDateList) 
	{
		RecordType fieldServiceRT = SMAX_PS_Utility.getRecTypeDevNameMap('SVMXC__Service_Order__c').get('Field_Service');
		List<SVMXC__Service_Order__c> woList = new List<SVMXC__Service_Order__c>();

		for (SMAX_PS_EntitlementDate__c ed : entDateList) {
			SVMXC__Installed_Product__c ip = ed.SMAX_PS_CoveredProduct__r.SVMXC__Installed_Product__r;			
			
			SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
			wo.RecordTypeId = fieldServiceRT.Id;
			wo.SVMXC__Order_Status__c = 'Initializing';
			wo.SVMXC__Billing_Type__c = 'Contract';
			wo.SVMXC__Order_Type__c = ed.SMAX_PS_Entitlement__r.SMAX_PS_EntitlementTypeName__c;
			if (wo.SVMXC__Order_Type__c == null || String.isBlank(wo.SVMXC__Order_Type__c))
			{
				// SVMXCFG-999 Scheduled WO - Do not create without Order Type
				wo.addError('Cannot create a Work Order without an Order Type.');
				woList.add(wo);
				continue;
			}

			if (ed.SMAX_PS_ContractItem__r.SVMX_PS_Parent_Contract__r.SVMXC__Active__c == false)
			{
				// SVMXCFG-1005 Scheduled Work Orders & "Credit Okay"
				wo.addError('Cannot create a Work Order when Service Contract is on Credit Hold.');
				woList.add(wo);
				continue;
			}

			wo.SVMXC__Priority__c = '3'; // Service Medium

			if (ip.SVMXC__Site__c == null || ip.SVMXC__Site__r.SVMXC__Account__c == null)
			{
				// SVMXCFG-699 Scheduled WO - Do not create without related data
				wo.addError('Cannot create a Work Order on an IP without a Location or Account.');
				woList.add(wo);
				continue;
			}

			// Accounts / Master Data
			wo.SVMXC__Company__c = ip.SVMXC__Site__r.SVMXC__Account__c;
			wo.SMAX_PS_ShipTo__c = ip.SVMXC__Site__r.SMAX_PS_ShipTo__c;
			wo.SMAX_PS_BillTo__c = ip.SVMXC__Site__r.SMAX_PS_BillTo__c;
			wo.SMAX_PS_Payer__c = ip.SVMXC__Site__r.SMAX_PS_Payer__c;
			// QUESTION: Should we instead use the ContractItem fields for ShipTo, BillTo, SoldTo, Payer?
			wo.SVMXC__Site__c = ip.SVMXC__Site__c;
			wo.SVMXC__Product__c = ip.SVMXC__Product__c;
			wo.SVMXC__Component__c = ed.SMAX_PS_CoveredProduct__r.SVMXC__Installed_Product__c;
			//wo.SVMXC__Contact__c = ip.SVMXC__Contact__c;
			wo.SVMXC__Contact__c = ed.SMAX_PS_ContractItem__r.SVMX_PS_Parent_Contract__r.SVMXC__Contact__c;

			wo.SVMXC__Scheduled_Date__c = ed.SMAX_PS_PlannedDate__c;
			// SVMXINT-562 Basic Start Date
			wo.SMAX_PS_Customer_Required_Start_Date__c = ed.SMAX_PS_PlannedDate__c;
			// ONLY run auto-assignment when WO Scheduled for 2+ weeks out
			wo.SMAX_PS_Perform_Auto_Assignment__c = (wo.SVMXC__Scheduled_Date__c >= Date.today().addDays(14));

			// Entitlement results
			wo.SVMXC__Service_Contract__c = ed.SMAX_PS_ContractItem__r.SVMX_PS_Parent_Contract__c;
			wo.SMAX_PS_ContractItem__c = ed.SMAX_PS_ContractItem__c;
			wo.SMAX_PS_ContractEntitlement__c = ed.SMAX_PS_Entitlement__c;										
			wo.SMAX_PS_CoveredProduct__c = ed.SMAX_PS_CoveredProduct__c;
			wo.SVMXC__Auto_Entitlement_Status__c = 'Success';
			wo.SVMXC__Entitlement_Type__c = 'SCHEDULED';
			wo.SVMXC__Is_Entitlement_Performed__c = TRUE;
			wo.SVMXC__Entitlement_Notes__c = 'Scheduled Entitlement Completed and is Successful.';
			wo.SVMXC__Perform_Auto_Entitlement__c = FALSE;

			// SVMXCFG-523: Problem Summary: MM/YYYY-Maintenance Activity Type-Technical ID-Building-Room
			Datetime entDate = Datetime.newInstance(ed.SMAX_PS_PlannedDate__c, Time.newInstance(0, 0, 0, 0));
			String ps = entDate.format('MM/yyyy') + '-' + ed.SMAX_PS_Entitlement__r.SMAX_PS_EntitlementType__c;
			if (String.isNotBlank(ip.SMAX_PS_Technical_ID_Number__c))
				ps += '-' + ip.SMAX_PS_Technical_ID_Number__c;
			if (String.isNotBlank(ip.SMAX_PS_Building__c))
				ps += '-' + ip.SMAX_PS_Building__c;
			if (String.isNotBlank(ip.SMAX_PS_Room__c))
				ps += '-' + ip.SMAX_PS_Room__c;

			wo.SVMXC__Problem_Description__c = ps;
			wo.SVMX_PS_Problem_Summary__c = (ps.length() > 40) ? ps.substring(0, 37) + '...' : ps;

			// SVMXCFG-685 - Map other Service Contract fields to WO
			String slaTerms = ed.SMAX_PS_ContractItem__r.SMAX_PS_SLA_Terms_Notes__c;
			if (slaTerms != null && slaTerms.length() >= 255)
			{
				slaTerms = slaTerms.substring(0, 252) + '...';
			}
			wo.SMAX_PS_SLA_Terms_Notes__c = slaTerms;
			wo.SMAX_PS_IsEntitledWarranty__c = ed.SMAX_PS_ContractItem__r.SMAX_PS_Is_Warranty__c;
			wo.SMAX_PS_Is_Enterprise__c = ed.SMAX_PS_ContractItem__r.SMAX_PS_Is_Enterprise__c;
			wo.SMAX_PS_Offline_Contract_Discounts__c = SMAX_PS_AutoEntitlement.calculateOfflineDiscounts(ed.SMAX_PS_Entitlement__r);

			// SVMXCFG-916 Copy Service Contract PO Number to WO
			wo.SMAX_PS_CustomerPO__c = ed.SMAX_PS_ContractItem__r.SVMX_PS_Parent_Contract__r.SMAX_PS_PONumber__c;
			//wo.SMAX_PS_CustomerPODate__c = Date.today();

			woList.add(wo);
		}

		List<SMAX_PS_ErrorLog__c> logs = new List<SMAX_PS_ErrorLog__c>();
		Database.SaveResult[] results = Database.insert(woList, false);
		for (Integer i = 0; i < results.size(); i++)
		{
			Database.SaveResult result = results[i];
			SMAX_PS_EntitlementDate__c ed = entDateList[i];
			SVMXC__Service_Order__c wo = woList[i];
			if (!result.isSuccess())
			{
				String errorMsg = 'Error inserting Work Order for Entitlement Date: ' + ed.Name + ' - ' + result.getErrors();
				System.debug('SCHED_WO: ' + errorMsg);
				logs.add(SMAX_PS_LogUtility.createLog(SMAX_PS_LogUtility.ERROR, errorMsg, 'SMAX_PS_CreateScheduledWorkOrdersBatch', null, ed.Id));
			}
			else
			{
				System.debug('SCHED_WO: Success creating Scheduled Work Order: ' + wo.Id);
				ed.SMAX_PS_WorkOrder__c = wo.Id;
			}
		}           

		update entDateList;

		if (!logs.isEmpty())
			insert logs;
	}
	
	global void finish(Database.BatchableContext BC) 
	{
	}

}