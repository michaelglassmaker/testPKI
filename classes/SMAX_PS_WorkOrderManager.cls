/**
 *  Apex Class for Work Order [SVMXC__Service_Order__c] Business Logic.
 *  2017-09-21      Veerendra Moodbidri       Initial creation, for Work Order Outbound Integration.
 *  2017-2018       Frank VanLoon             Multiple additions: CopyRelatedData, UpdateMapedValues, SubmitLines, etc.
 *  2018-03-16.     MAPLES                    Added to copyRelatedDate method the mapping for Payer Address so it can be used in creation of Parts order JIRA 392
 */
public with sharing class SMAX_PS_WorkOrderManager {

	private SMAX_PS_WorkOrderManager() {
	}

	private static String WORK_COMPLETE = 'Work Complete';

	/**
	 * Use the AutoFieldMapping Custom Metadata Type to map fields.
	 * Should be called in the "before" trigger(s)
	 */
	public static void updateMappedValues(List<SVMXC__Service_Order__c> woList, Map<Id, SVMXC__Service_Order__c> oldMap)
	{
		if (!SMAX_PS_Utility.isActive('Work Order Update Mapped Values', 'Use the AutoFieldMapping Custom Metadata Type to map fields.'))
			return;

		Profile prof = SMAX_PS_Utility.getCurrentUserProfile();
		if (oldMap == null && prof != null && prof.Name.containsIgnoreCase('Integration'))
		{
			// If created by Integration.. reverse map the values.
			SMAX_PS_Utility.updateMappedValues('SVMXC__Service_Order__c', woList, oldMap, TRUE);
		}
		else
		{
			SMAX_PS_Utility.updateMappedValues('SVMXC__Service_Order__c', woList, oldMap, FALSE);
		}
	}

	public static void syncScheduledDate(List<SVMXC__Service_Order__c> woList, Map<Id, SVMXC__Service_Order__c> oldMap)
	{
		if (!SMAX_PS_Utility.isActive('Work Order Sched Date', 'Update the WO Scheduled Date from the updated Scheduled Datetime.'))
			return;

		if (oldMap == null) // INSERT
		{
			// SVMXINT-498: IF (INSERT by BOOMI) AND (ScheduledDate is in PAST) THEN change to TODAY
			Profile prof = SMAX_PS_Utility.getCurrentUserProfile();
			Boolean isIntegration = (prof != null && prof.Name.containsIgnoreCase('Integration'));
			if (isIntegration)
			{
				Date today = Date.today();
				for (SVMXC__Service_Order__c wo : woList)
				{
					if (wo.SVMXC__Scheduled_Date__c != null && wo.SVMXC__Scheduled_Date__c < today)
					{
						wo.SVMXC__Scheduled_Date__c = today;
					}
				}
			}
		}
		else // UPDATE
		{
			for (SVMXC__Service_Order__c wo : woList)
			{
				SVMXC__Service_Order__c old = (oldMap == null) ? null : oldMap.get(wo.Id);
				if (old != null && wo.SVMXC__Scheduled_Date_Time__c != null && wo.SVMXC__Scheduled_Date_Time__c != old.SVMXC__Scheduled_Date_Time__c)
				{
					wo.SVMXC__Scheduled_Date__c = wo.SVMXC__Scheduled_Date_Time__c.date();
				}
			}
		}
	}

	/**
	 * Copy Related Lookups and fields when Work Orders are Created.
	 * Should be called in the "before" trigger(s)
	 * ADDED support for BEFORE UPDATE.. when the IP Lookup changes for SVMXCFG-682
	 */
	public static void copyRelatedData(List<SVMXC__Service_Order__c> woNewList, Map<Id, SVMXC__Service_Order__c> oldMap)
	{
		if (!SMAX_PS_Utility.isActive('Work Order Copy Related Data', 'Copy Related Lookups and fields when Work Orders are Created.'))
			return;

		// SVMXINT-536 WO Load: Do not recalculate Customer Master lookups
		Boolean isIntegration = SMAX_PS_Utility.isCurrentUserIntegrationProfile();

		// First pass.. IPs and Contacts
		Set<Id> ipIds = new Set<Id>();
		Set<Id> contactIds = new Set<Id>();
		Set<Id> acctIds = new Set<Id>();
		for (SVMXC__Service_Order__c wo : woNewList)
		{
			SVMXC__Service_Order__c old = (oldMap == null) ? null : oldMap.get(wo.Id);
			if (old == null || old.SVMXC__Component__c != wo.SVMXC__Component__c)
			{
				if (old != null)
				{
					// SVMXCFG-682 Wipe out fields to make sure they get replaced from IP / Location..
					wo.SVMXC__Site__c = null;
					wo.SVMXC__Company__c = null;
					wo.SMAX_PS_ShipTo__c = null;
					wo.SMAX_PS_BillTo__c = null;
					wo.SMAX_PS_Payer__c = null;
					wo.SMAX_PS_Local_Language_Bill_To_Account__c = null;
					wo.SMAX_PS_Local_Language_Ship_To_Account__c = null;
				}

				// SVMXINT-561 WO Basic Start Date - default to same vlaue
				if (wo.SVMXC__Scheduled_Date__c == null)
					wo.SVMXC__Scheduled_Date__c = wo.SMAX_PS_Customer_Required_Start_Date__c;
				if (wo.SVMXC__Scheduled_Date__c == null)
					wo.SVMXC__Scheduled_Date__c = Date.today();
				if (wo.SVMXC__Component__c != null)
					ipIds.add(wo.SVMXC__Component__c);
				if (wo.SVMXC__Contact__c != null)
					contactIds.add(wo.SVMXC__Contact__c);
				if (wo.SVMXC__Company__c != null && isIntegration)
					acctIds.add(wo.SVMXC__Company__c);

				// SVMXINT-638 WO Local Language Cust Numbers
				if (wo.SMAX_PS_Local_Language_Bill_To_Account__c != null && isIntegration)
					acctIds.add(wo.SMAX_PS_Local_Language_Bill_To_Account__c);
				if (wo.SMAX_PS_Local_Language_Ship_To_Account__c != null && isIntegration)
					acctIds.add(wo.SMAX_PS_Local_Language_Ship_To_Account__c);

				// SVMXCFG-1057 Country without IP nor Location
				if (wo.SVMXC__Component__c == null && wo.SVMXC__Site__c == null && wo.SVMXC__Company__c != null)
					acctIds.add(wo.SVMXC__Company__c);
			}
		}

		if (ipIds.isEmpty() && contactIds.isEmpty() && acctIds.isEmpty())
			return;

		Map<Id, SVMXC__Installed_Product__c> ipMap = null;
		if (!ipIds.isEmpty())
		{
			// SVMXCFG-794 Copy Payer E-Invoice Fields to WO
			ipMap = new Map<Id, SVMXC__Installed_Product__c>([SELECT Id, Name, SMAX_PS_ModelSeries__c, SVMXC__Site__c,
					SVMXC__Preferred_Technician__c, SMAX_PS_CatalogProfile__c, SMAX_PS_ModelNumber__c, SMAX_PS_IsMedicalDevice__c,
					SMAX_PS_Technical_ID_Number__c, SMAX_PS_ThirdPartyVendorName__c, SMAX_PS_Field_Notes__c,
					SVMXC__Product__c, SVMXC__Product__r.SMAX_PS_Super_Business_Unit__c, SVMXC__Product__r.SVMXC__Product_Line__c,
					SMAX_PS_SoldTo_Account__c, SMAX_PS_ShipTo_Account__c, SMAX_PS_BillTo_Account__c, SMAX_PS_Payer_Account__c,
					SMAX_PS_SoldTo_Account__r.ShippingStreet, SMAX_PS_SoldTo_Account__r.ShippingCity, SMAX_PS_SoldTo_Account__r.ShippingState,
					SMAX_PS_SoldTo_Account__r.ShippingPostalCode, SMAX_PS_SoldTo_Account__r.ShippingCountry,
					SMAX_PS_System_ID__c, SVMXC__Asset_Tag__c, SMAX_PS_Equipment_ID__c,
					SMAX_PS_Payer_Account__r.PKI_SAP_EInvoice_Platform_Id__c, SMAX_PS_Payer_Account__r.PKI_SAP_EInvoice_Customer_Id__c,
					SMAX_PS_LL_BillTo_Account__c, SMAX_PS_LL_BillTo_Account__r.Name,
					SMAX_PS_LL_BillTo_Account__r.ShippingStreet, SMAX_PS_LL_BillTo_Account__r.ShippingCity, SMAX_PS_LL_BillTo_Account__r.ShippingState,
					SMAX_PS_LL_BillTo_Account__r.ShippingPostalCode, SMAX_PS_LL_BillTo_Account__r.ShippingCountry,
					SMAX_PS_LL_ShipTo_Account__c, SMAX_PS_LL_ShipTo_Account__r.Name,
					SMAX_PS_LL_ShipTo_Account__r.ShippingStreet, SMAX_PS_LL_ShipTo_Account__r.ShippingCity, SMAX_PS_LL_ShipTo_Account__r.ShippingState,
					SMAX_PS_LL_ShipTo_Account__r.ShippingPostalCode, SMAX_PS_LL_ShipTo_Account__r.ShippingCountry
			FROM SVMXC__Installed_Product__c WHERE Id IN :ipIds]);
		}

		Map<Id, Contact> contactMap = null;
		if (!contactIds.isEmpty())
		{
			contactMap = new Map<Id, Contact>([SELECT Id, Name, Phone, Email
			FROM Contact WHERE Id IN :contactIds]);
		}

		Map<Id, Account> acctMap = new Map<Id, Account>();
		if (!acctIds.isEmpty())
		{
			acctMap = new Map<Id, Account>([SELECT Id, Name,
					ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry
			FROM Account WHERE Id IN :acctIds]);
		}

		// Load the Custom Setting for converting "Catalog Profile" to "Code Family"
		Map<String, String> profileFamilyMap = new Map<String, String>();
		for (SMAX_PS_Catalog_Profile__c catProf : SMAX_PS_Catalog_Profile__c.getall().values())
		{
			profileFamilyMap.put(catProf.SMAX_PS_Catalog_Profile__c, catProf.SMAX_PS_Code_Family__c);
		}

		// OBSOLETE Equipment Products for RMA/Loaner..
		Map<Id, Id> woProdMap = new Map<Id, Id>();

		// SVMXINT-516 : Use IP Customer Master Lookups first - SoldTo will be filled in SFM .. can't use basic null logic
		Map<Id, Account> woSoldToMap = new Map<Id, Account>();
		for (SVMXC__Service_Order__c wo : woNewList)
		{
			if (wo.SVMXC__Component__c != null)
			{
				SVMXC__Installed_Product__c ip = (ipMap == null) ? null : ipMap.get(wo.SVMXC__Component__c);
				if (ip != null)
				{
					wo.SVMXC__Preferred_Technician__c = ip.SVMXC__Preferred_Technician__c;
					wo.SMAX_PS_ModelSeries__c = ip.SMAX_PS_ModelSeries__c;
					wo.SMAX_PS_Model_Number__c = ip.SMAX_PS_ModelNumber__c;
					wo.SMAX_PS_IsMedicalDevice__c = ip.SMAX_PS_IsMedicalDevice__c;
					wo.SMAX_PS_Technical_ID_Number__c = ip.SMAX_PS_Technical_ID_Number__c;
					wo.SMAX_PS_Vendor__c = ip.SMAX_PS_ThirdPartyVendorName__c;

					//SVMXCFG-687 - Add Installed Product System ID to WO
					wo.SMAX_PS_System_ID__c = ip.SMAX_PS_System_ID__c;
					// SVMXCFG-763 - System ID, Equipment ID from IP
					wo.SMAX_PS_Asset_ID__c = ip.SVMXC__Asset_Tag__c;
					wo.SMAX_PS_Equipment_ID__c = ip.SMAX_PS_Equipment_ID__c;

					// Copy Location from IP if blank on WO
					if (wo.SVMXC__Site__c == null)
					{
						wo.SVMXC__Site__c = ip.SVMXC__Site__c;
					}
					// JIRA #395 - Fault Code Debrief
					if (ip.SMAX_PS_CatalogProfile__c != null)
					{
						wo.SMAX_PS_Fault_Code_Family__c = profileFamilyMap.get(ip.SMAX_PS_CatalogProfile__c);
					}
					// JIRA SVMXCFG-357 - Copy Super Business Unit from IP's Product
					if (ip.SVMXC__Product__c != null)
					{
						wo.SMAX_PS_Super_Business_Unit__c = ip.SVMXC__Product__r.SMAX_PS_Super_Business_Unit__c;
						// SVMXCFG-1137 Copy the IP Product Line to the Work Order
						wo.SMAX_PS_IP_Product_Line__c = ip.SVMXC__Product__r.SVMXC__Product_Line__c;
						// OBSOLETE Equipment Products for RMA/Loaner..
						woProdMap.put(wo.Id, ip.SVMXC__Product__c);
					}
					// SVMXCFG-610 - Notes fields from IP/Location
					wo.SMAX_PS_Field_Notes__c = ip.SMAX_PS_Field_Notes__c;

					if (!isIntegration)
					{
						// SVMXINT-516 : Use IP Customer Master Lookups first
						if (ip.SMAX_PS_SoldTo_Account__c != null)
						{
							woSoldToMap.put(wo.Id, ip.SMAX_PS_SoldTo_Account__r);
							wo.SVMXC__Company__c = ip.SMAX_PS_SoldTo_Account__c;
						}
						if (ip.SMAX_PS_ShipTo_Account__c != null)
						{
							wo.SMAX_PS_ShipTo__c = ip.SMAX_PS_ShipTo_Account__c;
						}
						if (ip.SMAX_PS_BillTo_Account__c != null)
						{
							wo.SMAX_PS_BillTo__c = ip.SMAX_PS_BillTo_Account__c;
						}
						if (ip.SMAX_PS_Payer_Account__c != null)
						{
							wo.SMAX_PS_Payer__c = ip.SMAX_PS_Payer_Account__c;
							// SVMXCFG-794 Copy Payer E-Invoice Fields to WO
							wo.SMAX_PS_EInvoice_Platform_Id__c = ip.SMAX_PS_Payer_Account__r.PKI_SAP_EInvoice_Platform_Id__c;
							wo.SMAX_PS_EInvoice_Customer_Id__c = ip.SMAX_PS_Payer_Account__r.PKI_SAP_EInvoice_Customer_Id__c;
						}
						// SVMXCFG-903 Copy Local Language Accounts to WO
						if (ip.SMAX_PS_LL_BillTo_Account__c != null)
						{
							wo.SMAX_PS_Local_Language_Bill_To_Account__c = ip.SMAX_PS_LL_BillTo_Account__c;
							wo.SMAX_PS_LocalLanguageBillTo__c = ip.SMAX_PS_LL_BillTo_Account__r.Name;
							// SVMXCFG-993 Copy Local Lang address too
							wo.SMAX_PS_Local_Language_Bill_To_Street__c = ip.SMAX_PS_LL_BillTo_Account__r.ShippingStreet;
							wo.SMAX_PS_Local_Lang_Bill_To_Addr_Long__c = ip.SMAX_PS_LL_BillTo_Account__r.ShippingCity
									+ ' ' + ip.SMAX_PS_LL_BillTo_Account__r.ShippingState
									+ ' ' + ip.SMAX_PS_LL_BillTo_Account__r.ShippingPostalCode
									+ ' ' + ip.SMAX_PS_LL_BillTo_Account__r.ShippingCountry;
						}
						if (ip.SMAX_PS_LL_ShipTo_Account__c != null)
						{
							wo.SMAX_PS_Local_Language_Ship_To_Account__c = ip.SMAX_PS_LL_ShipTo_Account__c;
							wo.SMAX_PS_LocalLanguageShipTo__c = ip.SMAX_PS_LL_ShipTo_Account__r.Name;
							// SVMXCFG-993 Copy Local Lang address too
							wo.SMAX_PS_Local_Language_Ship_To_Street__c = ip.SMAX_PS_LL_ShipTo_Account__r.ShippingStreet;
							wo.SMAX_PS_Local_Lang_Ship_To_Addr_Long__c = ip.SMAX_PS_LL_ShipTo_Account__r.ShippingCity
									+ ' ' + ip.SMAX_PS_LL_ShipTo_Account__r.ShippingState
									+ ' ' + ip.SMAX_PS_LL_ShipTo_Account__r.ShippingPostalCode
									+ ' ' + ip.SMAX_PS_LL_ShipTo_Account__r.ShippingCountry;
						}
					}
				}
			}
			if (wo.SVMXC__Contact__c != null)
			{
				Contact c = (contactMap == null) ? null : contactMap.get(wo.SVMXC__Contact__c);
				if (c != null)
				{
					wo.SVMX_PS_Contact_Email__c = c.Email;
					wo.SMAX_PS_ContactName__c = c.Name;
					wo.SVMX_PS_Contact_Phone__c = c.Phone;
				}
			}

			// SVMXINT-638 WO Local Language Cust Numbers
			if (wo.SMAX_PS_Local_Language_Bill_To_Account__c != null && isIntegration)
			{
				Account acct = acctMap.get(wo.SMAX_PS_Local_Language_Bill_To_Account__c);
				if (acct != null)
				{
					wo.SMAX_PS_LocalLanguageBillTo__c = acct.Name;
					// SVMXCFG-993 Copy Local Lang address too
					wo.SMAX_PS_Local_Language_Bill_To_Street__c = acct.ShippingStreet;
					wo.SMAX_PS_Local_Lang_Bill_To_Addr_Long__c = acct.ShippingCity
							+ ' ' + acct.ShippingState
							+ ' ' + acct.ShippingPostalCode
							+ ' ' + acct.ShippingCountry;

				}
			}
			if (wo.SMAX_PS_Local_Language_Ship_To_Account__c != null && isIntegration)
			{
				Account acct = acctMap.get(wo.SMAX_PS_Local_Language_Ship_To_Account__c);
				if (acct != null)
				{
					wo.SMAX_PS_LocalLanguageShipTo__c = acct.Name;
					// SVMXCFG-993 Copy Local Lang address too
					wo.SMAX_PS_Local_Language_Ship_To_Street__c = acct.ShippingStreet;
					wo.SMAX_PS_Local_Lang_Ship_To_Addr_Long__c = acct.ShippingCity
							+ ' ' + acct.ShippingState
							+ ' ' + acct.ShippingPostalCode
							+ ' ' + acct.ShippingCountry;
				}
			}

			// SVMXCFG-1057 Country without IP nor Location
			if (wo.SVMXC__Component__c == null && wo.SVMXC__Site__c == null && wo.SVMXC__Company__c != null)
			{
				Account acct = acctMap.get(wo.SVMXC__Company__c);
				if (acct != null)
				{
					wo.SVMXC__Country__c = acct.ShippingCountry;
					wo.SMAX_PS_Account_Street__c = acct.ShippingStreet;
					wo.SMAX_PS_Account_City__c = acct.ShippingCity;
					wo.SMAX_PS_Account_State__c = acct.ShippingState;
					wo.SMAX_PS_Account_Zip_Code__c = acct.ShippingPostalCode;
					wo.SMAX_PS_Account_Country__c = acct.ShippingCountry;
				}
			}
		}

		// Second pass.. Locations (might have been filled in during first pass)
		Set<Id> locIds = new Set<Id>();
		for (SVMXC__Service_Order__c wo : woNewList)
		{
			if (wo.SVMXC__Site__c != null)
				locIds.add(wo.SVMXC__Site__c);
		}

		Map<Id, SVMXC__Site__c> locMap = null;
		if (!locIds.isEmpty())
		{
			// 2018-03-16 MAPLES - Added the new fields for Payer address so we can map to WO and then use in creation of Parts Order
			// SVMXCFG-794 Copy Payer E-Invoice Fields to WO
			locMap = new Map<Id, SVMXC__Site__c>([SELECT Id, Name, SMAX_PS_LocationCode__c, SMAX_PS_Geography__r.Name,
					SVMXC__Account__c, SMAX_PS_BillTo__c, SMAX_PS_Payer__c, SMAX_PS_ShipTo__c, SMAX_PS_MaintenancePlant__c,
					SMAX_PS_SalesOrg__c, CurrencyIsoCode, SVMX_PS_Location_Notes__c,
					SVMXC__Account__r.ShippingStreet, SVMXC__Account__r.ShippingCity, SVMXC__Account__r.ShippingState,
					SVMXC__Account__r.ShippingPostalCode, SVMXC__Account__r.ShippingCountry,
					SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Country__c, SVMXC__Zip__c,
					SMAX_PS_Payer__r.PKI_SAP_EInvoice_Platform_Id__c, SMAX_PS_Payer__r.PKI_SAP_EInvoice_Customer_Id__c,
					SMAX_PS_LL_BillTo__c, SMAX_PS_LL_BillTo__r.Name,
					SMAX_PS_LL_BillTo__r.ShippingStreet, SMAX_PS_LL_BillTo__r.ShippingCity, SMAX_PS_LL_BillTo__r.ShippingState,
					SMAX_PS_LL_BillTo__r.ShippingPostalCode, SMAX_PS_LL_BillTo__r.ShippingCountry,
					SMAX_PS_LL_ShipTo__c, SMAX_PS_LL_ShipTo__r.Name,
					SMAX_PS_LL_ShipTo__r.ShippingStreet, SMAX_PS_LL_ShipTo__r.ShippingCity, SMAX_PS_LL_ShipTo__r.ShippingState,
					SMAX_PS_LL_ShipTo__r.ShippingPostalCode, SMAX_PS_LL_ShipTo__r.ShippingCountry
			FROM SVMXC__Site__c WHERE Id IN :locIds]);
		}

		// OBSOLETE Equipment Products for RMA/Loaner..
		Map<Id, String> woPlantMap = new Map<Id, String>();

		Set<String> locExtIds = new Set<String>();
		for (SVMXC__Service_Order__c wo : woNewList)
		{
			if (wo.SVMXC__Site__c != null)
			{
				SVMXC__Site__c loc = (locMap == null) ? null : locMap.get(wo.SVMXC__Site__c);
				if (loc != null)
				{
					if (!isIntegration)
					{
						// SVMXINT-516 : Use IP Customer Master Lookups first
						if (!woSoldToMap.containsKey(wo.Id))
						{
							woSoldToMap.put(wo.Id, loc.SVMXC__Account__r);
							wo.SVMXC__Company__c = loc.SVMXC__Account__c;
						}
						if (wo.SMAX_PS_BillTo__c == null)
						{
							wo.SMAX_PS_BillTo__c = loc.SMAX_PS_BillTo__c;
						}
						if (wo.SMAX_PS_Payer__c == null)
						{
							wo.SMAX_PS_Payer__c = loc.SMAX_PS_Payer__c;
							// SVMXCFG-794 Copy Payer E-Invoice Fields to WO
							wo.SMAX_PS_EInvoice_Platform_Id__c = loc.SMAX_PS_Payer__r.PKI_SAP_EInvoice_Platform_Id__c;
							wo.SMAX_PS_EInvoice_Customer_Id__c = loc.SMAX_PS_Payer__r.PKI_SAP_EInvoice_Customer_Id__c;
						}
						if (wo.SMAX_PS_ShipTo__c == null)
						{
							wo.SMAX_PS_ShipTo__c = loc.SMAX_PS_ShipTo__c;
						}
						// SVMXCFG-903 Copy Local Language Accounts to WO
						if (wo.SMAX_PS_Local_Language_Bill_To_Account__c == null && loc.SMAX_PS_LL_BillTo__c != null)
						{
							wo.SMAX_PS_Local_Language_Bill_To_Account__c = loc.SMAX_PS_LL_BillTo__c;
							wo.SMAX_PS_LocalLanguageBillTo__c = loc.SMAX_PS_LL_BillTo__r.Name;
							// SVMXCFG-993 Copy Local Lang address too
							wo.SMAX_PS_Local_Language_Bill_To_Street__c = loc.SMAX_PS_LL_BillTo__r.ShippingStreet;
							wo.SMAX_PS_Local_Lang_Bill_To_Addr_Long__c = loc.SMAX_PS_LL_BillTo__r.ShippingCity
									+ ' ' + loc.SMAX_PS_LL_BillTo__r.ShippingState
									+ ' ' + loc.SMAX_PS_LL_BillTo__r.ShippingPostalCode
									+ ' ' + loc.SMAX_PS_LL_BillTo__r.ShippingCountry;
						}
						if (wo.SMAX_PS_Local_Language_Ship_To_Account__c == null && loc.SMAX_PS_LL_ShipTo__c != null)
						{
							wo.SMAX_PS_Local_Language_Ship_To_Account__c = loc.SMAX_PS_LL_ShipTo__c;
							wo.SMAX_PS_LocalLanguageShipTo__c = loc.SMAX_PS_LL_ShipTo__r.Name;
							// SVMXCFG-993 Copy Local Lang address too
							wo.SMAX_PS_Local_Language_Ship_To_Street__c = loc.SMAX_PS_LL_ShipTo__r.ShippingStreet;
							wo.SMAX_PS_Local_Lang_Ship_To_Addr_Long__c = loc.SMAX_PS_LL_ShipTo__r.ShippingCity
									+ ' ' + loc.SMAX_PS_LL_ShipTo__r.ShippingState
									+ ' ' + loc.SMAX_PS_LL_ShipTo__r.ShippingPostalCode
									+ ' ' + loc.SMAX_PS_LL_ShipTo__r.ShippingCountry;
						}
					}

					// 2018-03-16 MAPLES - added Address mapping for use on create of Parts Order **JIRA 392
					// 2018-05-09 Frank - Refactored for SVMXINT-516 and SVMXINT-536
					Account soldToAccount = (isIntegration) ? acctMap.get(wo.SVMXC__Company__c) : woSoldToMap.get(wo.Id);
					if (soldToAccount != null)
					{
						wo.SMAX_PS_Account_Street__c = soldToAccount.ShippingStreet;
						wo.SMAX_PS_Account_City__c = soldToAccount.ShippingCity;
						wo.SMAX_PS_Account_State__c = soldToAccount.ShippingState;
						wo.SMAX_PS_Account_Zip_Code__c = soldToAccount.ShippingPostalCode;
						wo.SMAX_PS_Account_Country__c = soldToAccount.ShippingCountry;
					}

					// SVMXCFG-329 - Copy Currency from Payer
					//if (loc.SMAX_PS_Payer__c != null) { wo.CurrencyIsoCode = loc.SMAX_PS_Payer__r.CurrencyIsoCode; }
					// SVMXINT-475 - Copy the Currency Code from the Functional Location instead
					wo.CurrencyIsoCode = loc.CurrencyIsoCode;
					wo.SMAX_PS_LocationCode__c = loc.SMAX_PS_LocationCode__c;
					wo.SMAX_PS_Geography__c = (loc.SMAX_PS_Geography__r != null) ? loc.SMAX_PS_Geography__r.Name : null;
					wo.SMAX_PS_SalesOrg__c = loc.SMAX_PS_SalesOrg__c;
					// SVMXCFG-483 - Blank "Service Location" on WO
					if (String.isBlank(wo.SVMXC__Street__c))
					{
						wo.SVMXC__Street__c = loc.SVMXC__Street__c;
						wo.SVMXC__City__c = loc.SVMXC__City__c;
						wo.SVMXC__State__c = loc.SVMXC__State__c;
						wo.SVMXC__Zip__c = loc.SVMXC__Zip__c;
					}
					wo.SVMXC__Country__c = loc.SVMXC__Country__c;
					if (loc.SMAX_PS_MaintenancePlant__c != null)
					{
						wo.SMAX_PS_ExpenseLocationNumber__c = loc.SMAX_PS_MaintenancePlant__c + 'F000';
						locExtIds.add(wo.SMAX_PS_ExpenseLocationNumber__c);
						woPlantMap.put(wo.Id, loc.SMAX_PS_MaintenancePlant__c);
					}
					// SVMXCFG-610 - Notes fields from IP/Location
					wo.SMAX_PS_Location_Notes__c = loc.SVMX_PS_Location_Notes__c;
				}
			}
		}

		// Third pass.. Expense Locations
		// JIRA #383 - Expense Debrief Tab
		// SVMXCFG-903 Disabling the Expense Storage Location code
//      if (!locExtIds.isEmpty())
//      {
//          // Fill in Lookup: SMAX_PS_ExpenseStorageLocation__c
//          Map<String, SVMXC__Site__c> expLocMap = new Map<String, SVMXC__Site__c>();
//          for (SVMXC__Site__c loc : [SELECT Id, Name, SVMX_PS_External_ID__c FROM SVMXC__Site__c WHERE SVMX_PS_External_ID__c IN :locExtIds])
//          {
//              expLocMap.put(loc.SVMX_PS_External_ID__c, loc);
//          }
//
//          for (SVMXC__Service_Order__c wo : woNewList)
//          {
//              if (wo.SMAX_PS_ExpenseLocationNumber__c != null && wo.SMAX_PS_ExpenseStorageLocation__c == null)
//              {
//                  SVMXC__Site__c loc = expLocMap.get(wo.SMAX_PS_ExpenseLocationNumber__c);
//                  if (loc != null)
//                      wo.SMAX_PS_ExpenseStorageLocation__c = loc.Id;
//              }
//          }
//      }

		// OBSOLETE Equipment Products for RMA/Loaner..
		Set<String> plants = new Set<String>(woPlantMap.values());
		Set<Id> prodIds = new Set<Id>(woProdMap.values());

		if (plants.isEmpty() || prodIds.isEmpty())
		{
			return;
		}

		List<SMAX_PS_ProductPlant__c> allProductPlants = [SELECT Id, Name, SMAX_PS_Product__c, SMAX_PS_Plant__c,
				BD_Return_Part__c, BD_Return_Part_Number__c, BD_Credit_Relevant_Part__c,
				SMAX_PS_Product__r.Partnum__c
		FROM SMAX_PS_ProductPlant__c WHERE SMAX_PS_Product__c IN :prodIds AND SMAX_PS_Plant__c IN :plants];
		Map<String, SMAX_PS_ProductPlant__c> ppMap = new Map<String, SMAX_PS_ProductPlant__c>();
		for (SMAX_PS_ProductPlant__c pp : allProductPlants)
		{
			String key = pp.SMAX_PS_Product__c + '-' + pp.SMAX_PS_Plant__c;
			ppMap.put(key, pp);
		}

		for (SVMXC__Service_Order__c wo : woNewList)
		{
			Id productId = woProdMap.get(wo.Id);
			String plant = woPlantMap.get(wo.Id);

			String key = productId + '-' + plant;
			SMAX_PS_ProductPlant__c pp = ppMap.get(key);
			if (pp != null)
			{
				wo.BD_Equipment_Part_Return_Number__c = (pp.BD_Return_Part_Number__c == null) ?
						pp.SMAX_PS_Product__r.Partnum__c : pp.BD_Return_Part_Number__c;
			}
		}
	}

	/**
	 * Update the WO TechnicianSalesOrg field from the Tech Storage Location.
	 * Should be called in the "before" trigger(s)
	 */
	public static void updateTechnicianDetails(List<SVMXC__Service_Order__c> woList, Map<Id, SVMXC__Service_Order__c> oldMap)
	{
		if (!SMAX_PS_Utility.isActive('Work Order Tech Details', 'Update the WO SalesOrg, Tech Email, Owner and other details from the Technician and related records.'))
			return;

		Set<Id> techIds = new Set<Id>();
		List<SVMXC__Service_Order__c> woTechUpdates = new List<SVMXC__Service_Order__c>();
		List<SVMXC__Service_Order__c> woPrevTechUpdates = new List<SVMXC__Service_Order__c>();
		for (SVMXC__Service_Order__c wo : woList)
		{
			SVMXC__Service_Order__c old = (oldMap == null) ? null : oldMap.get(wo.Id);
			if (wo.SVMXC__Group_Member__c != null && (old == null || wo.SVMXC__Group_Member__c != old.SVMXC__Group_Member__c))
			{
				techIds.add(wo.SVMXC__Group_Member__c);
				woTechUpdates.add(wo);
			}
			// SVMXCFG-529 - Collect "Previous" Tech Ids
			if (old != null && old.SVMXC__Group_Member__c != null && wo.SVMXC__Group_Member__c != old.SVMXC__Group_Member__c)
			{
				techIds.add(old.SVMXC__Group_Member__c);
				woPrevTechUpdates.add(wo);
			}
		}

		if (!techIds.isEmpty())
		{
			// SVMXCFG-1092 Lookup the "TPV Queue"
			SMAX_PS_Assignment_Settings__c assignmentSettings = SMAX_PS_Assignment_Settings__c.getInstance();
			String tpvQueueName = (assignmentSettings == null) ? null : assignmentSettings.SMAX_PS_TPV_Queue__c;
			if (tpvQueueName == null && Test.isRunningTest())
			{
				tpvQueueName = 'SMAX_PS_TPV_Work_Orders';
			}
			Group tpvQueue = (tpvQueueName == null) ? null :
					[SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = :tpvQueueName LIMIT 1];

			Map<Id, SVMXC__Service_Group_Members__c> techMap = new Map<Id, SVMXC__Service_Group_Members__c>([SELECT Id, Name,
					SVMXC__Inventory_Location__c, SVMXC__Inventory_Location__r.SMAX_PS_SalesOrg__c, SVMXC__Email__c,
					SVMXC__Third_Party__c, SVMXC__Salesforce_User__c, BD_Depot_Queue_Id__c
				FROM SVMXC__Service_Group_Members__c WHERE Id IN :techIds]);
			// SVMXCFG-297 -- Fill in the "Technician Sales Org"
			for (SVMXC__Service_Order__c wo : woTechUpdates)
			{
				Id techId = wo.SVMXC__Group_Member__c;
				if (techMap.containsKey(techId))
				{
					SVMXC__Service_Group_Members__c tech = techMap.get(techId);
					if (tech.SVMXC__Inventory_Location__c != null)
					{
						wo.SMAX_PS_TechnicianSalesOrg__c = tech.SVMXC__Inventory_Location__r.SMAX_PS_SalesOrg__c;
					}
					// SVMXCFG-824 Fill in the Member Email when Tech changes
					wo.SVMXC__Member_Email__c = tech.SVMXC__Email__c;

					// SVMXCFG-1092 If assigned to TPV, change Owner to "TPV Queue"
					if (tech.SVMXC__Third_Party__c == true && tech.SVMXC__Salesforce_User__c == null
							&& tpvQueue != null)
					{
						wo.OwnerId = tpvQueue.Id;
					}

					// ITSFDC-509 If assigned to a "Depot Work Center", update Owner & RT = Depot
					if (tech.BD_Depot_Queue_Id__c != null && tech.SVMXC__Salesforce_User__c == null)
					{
						wo.OwnerId = tech.BD_Depot_Queue_Id__c;
						RecordType depotRT = SMAX_PS_Utility.getRecordType('SVMXC__Service_Order__c', 'Depot_Repair');
						if (depotRT != null)
						{
							wo.RecordTypeId = depotRT.Id;
						}
					}
				}
			}

			// SVMXCFG-529 - Fill in "Previous" Tech email
			for (SVMXC__Service_Order__c wo : woPrevTechUpdates)
			{
				SVMXC__Service_Order__c old = (oldMap == null) ? null : oldMap.get(wo.Id);
				if (old != null && old.SVMXC__Group_Member__c != null)
				{
					SVMXC__Service_Group_Members__c previous = techMap.get(old.SVMXC__Group_Member__c);
					if (previous != null)
					{
						//wo.SMAX_PS_Previous_Technician__c = previous.Id;
						wo.SMAX_PS_Previous_Technician_Email__c = previous.SVMXC__Email__c;
						// SVMXCFG-694 : Copy Previos Tech Name and a datestamp for reassign email
						wo.SMAX_PS_Previous_Technician_Name__c = previous.Name;
						wo.SMAX_PS_Technician_Reassignment_DateTime__c = System.now();
					}
				}
			}
		}
	}

	/**
	 * Update the WO TechnicianSalesOrg field from the Tech Storage Location.
	 * Should be called in the "before" trigger(s)
	 */
	public static void forceWorkOrderEvents(List<SVMXC__Service_Order__c> woNewList)
	{
		if (!SMAX_PS_Utility.isActive('Work Order Force Events', 'Create Work Order Platform Events when Work Orders are Created.'))
			return;

		List<SMAX_PS_WorkOrder_Event__e> events = new List<SMAX_PS_WorkOrder_Event__e>();

		Datetime twoMinAgo = Datetime.now().addMinutes(-2);
		if (Test.isRunningTest())
			twoMinAgo = Datetime.now();
		for (SVMXC__Service_Order__c workOrder : woNewList)
		{
			if (workOrder.SMAX_PS_ForceIntegration__c == FALSE)
				continue;

			System.debug('FORCE WO Event for WO->'+workOrder);
			Datetime lastForceDate = (workOrder.SMAX_PS_LastForceIntegration__c == null)
					? workOrder.CreatedDate : workOrder.SMAX_PS_LastForceIntegration__c;
			if (lastForceDate < twoMinAgo)
			{
				Boolean existsSAP = String.isNotEmpty(workOrder.SVMX_PS_External_ID__c);
				SMAX_PS_WorkOrder_Event__e iEvent = new SMAX_PS_WorkOrder_Event__e();
				if (!existsSAP)
				{
					iEvent.SMAX_PS_Action__c = 'CREATE';
					iEvent.SMAX_PS_WorkOrderId__c = workOrder.Id;
					events.add(iEvent);
				}
				else if (existsSAP && workOrder.SMAX_PS_SAP_SystemStatus__c != 'TECO')
				{
					iEvent.SMAX_PS_Action__c = 'UPDATE';
					iEvent.SMAX_PS_WorkOrderId__c = workOrder.Id;
					events.add(iEvent);
				}
				else if (existsSAP && workOrder.SMAX_PS_SAP_SystemStatus__c == 'TECO')
				{
					iEvent.SMAX_PS_Action__c = 'BILLING REQUEST';
					iEvent.SMAX_PS_WorkOrderId__c = workOrder.Id;
					events.add(iEvent);
				}
				workOrder.SMAX_PS_LastForceIntegration__c = Datetime.now();
			}
			workOrder.SMAX_PS_ForceIntegration__c = FALSE;
		}
		System.debug('FORCED WO Events->'+events);

		sendWorkOrderEvents(events);
	}

	/**
	 * Create Work Order Platform Events when Work Orders are Created.
	 * Should be called in the "after" trigger(s)
	 */
	public static void createWorkOrderEvents(List<SVMXC__Service_Order__c> woNewList, Map<Id, SVMXC__Service_Order__c> woOldMap)
	{
		if (!SMAX_PS_Utility.isActive('Work Order Create Events', 'Create Work Order Platform Events when Work Orders are Created.'))
			return;

		List<SMAX_PS_WorkOrder_Event__e> events = new List<SMAX_PS_WorkOrder_Event__e>();
		system.debug('woNewList->'+woNewList);

		if (!woNewList.isEmpty()){

			Boolean isIntegrationUser = SMAX_PS_Utility.isCurrentUserIntegrationProfile();
			for (SVMXC__Service_Order__c workOrder : woNewList)
			{
				Boolean existsSAP = String.isNotEmpty(workOrder.SVMX_PS_External_ID__c);
				SVMXC__Service_Order__c old = (woOldMap == null) ? null : woOldMap.get(workOrder.id);
				SMAX_PS_WorkOrder_Event__e iEvent = new SMAX_PS_WorkOrder_Event__e();
				if ((!existsSAP) && workOrder.SVMXC__Order_Status__c == 'Initializing'
						&& (old == null || old.SVMXC__Order_Status__c != workOrder.SVMXC__Order_Status__c))
				{
					iEvent.SMAX_PS_Action__c = 'CREATE';
					iEvent.SMAX_PS_WorkOrderId__c = workOrder.Id;
					events.add(iEvent);
				}
				else if (existsSAP && old != null
						&& ((workOrder.SVMXC__Order_Status__c == 'DMR Released' && workOrder.SVMXC__Order_Status__c != old.SVMXC__Order_Status__c)
						|| (workOrder.SMAX_PS_SAP_SystemStatus__c == 'TECO' && workOrder.SMAX_PS_SAP_SystemStatus__c != old.SMAX_PS_SAP_SystemStatus__c)) )
				{
					// SVMXINT-499 - Re-Order WO Event Logic - Moved this BEFORE the update below
					if (isBillable(workOrder))
					{
						iEvent.SMAX_PS_Action__c = 'BILLING REQUEST';
						iEvent.SMAX_PS_WorkOrderId__c = workOrder.Id;
						events.add(iEvent);
					}
					else
					{
						// No other action needed..
					}
				}
				else if ( existsSAP && old != null &&
						(old.SVMXC__Group_Member__c != workOrder.SVMXC__Group_Member__c ||
								old.SVMXC__Scheduled_Date__c != workOrder.SVMXC__Scheduled_Date__c ||
								old.SVMXC__Scheduled_Date_Time__c != workOrder.SVMXC__Scheduled_Date_Time__c ||
								old.SVMXC__Service_Contract__c != workOrder.SVMXC__Service_Contract__c ||
								old.SMAX_PS_ContractItem__c != workOrder.SMAX_PS_ContractItem__c ||
								//old.SVMXC__Canceled_Date_Time__c != workOrder.SVMXC__Canceled_Date_Time__c ||
								old.SMAX_PS_SettlementReciever__c != workOrder.SMAX_PS_SettlementReciever__c ||
								old.SMAX_PS_HSI1_Answer__c != workOrder.SMAX_PS_HSI1_Answer__c ||
								old.SMAX_PS_HSI2_Answer__c != workOrder.SMAX_PS_HSI2_Answer__c ||
								old.SMAX_PS_HSI3_Answer__c != workOrder.SMAX_PS_HSI3_Answer__c ||
								old.SVMXC__Priority__c != workOrder.SVMXC__Priority__c ||
								old.SVMXC__Contact__c != workOrder.SVMXC__Contact__c ||
								old.SMAX_PS_CustomerPO__c != workOrder.SMAX_PS_CustomerPO__c ||
								old.SMAX_PS_SAP_Activity_Status__c != workOrder.SMAX_PS_SAP_Activity_Status__c ||
								old.SMAX_PS_SAP_Order_Status__c != workOrder.SMAX_PS_SAP_Order_Status__c ||
								old.SVMX_PS_Problem_Summary__c != workOrder.SVMX_PS_Problem_Summary__c ||
								old.SVMXC__Problem_Description__c != workOrder.SVMXC__Problem_Description__c ||
								old.SVMX_PS_Internal_Notes__c != workOrder.SVMX_PS_Internal_Notes__c ||
								old.SMAX_PS_Internal_Description__c != workOrder.SMAX_PS_Internal_Description__c ||
								old.SMAX_PS_Q1_Response__c != workOrder.SMAX_PS_Q1_Response__c ||
								old.SMAX_PS_Q2_Response__c != workOrder.SMAX_PS_Q2_Response__c ||
								old.SMAX_PS_Q3_Response__c != workOrder.SMAX_PS_Q3_Response__c ||
								old.SMAX_PS_Q4_Response__c != workOrder.SMAX_PS_Q4_Response__c ||
								old.SMAX_PS_Q5_Response__c != workOrder.SMAX_PS_Q5_Response__c ||
								old.SMAX_PS_Customer_Order_Id__c != workOrder.SMAX_PS_Customer_Order_Id__c ||
								old.SMAX_PS_Customer_Required_Start_Date__c != workOrder.SMAX_PS_Customer_Required_Start_Date__c ||
								old.SVMXC__Company__c != workOrder.SVMXC__Company__c ||
								old.SMAX_PS_BillTo__c != workOrder.SMAX_PS_BillTo__c ||
								old.SMAX_PS_Payer__c != workOrder.SMAX_PS_Payer__c ||
								old.SMAX_PS_ShipTo__c != workOrder.SMAX_PS_ShipTo__c ||
								old.SMAX_PS_Local_Language_Bill_To_Account__c != workOrder.SMAX_PS_Local_Language_Bill_To_Account__c ||
								old.SMAX_PS_Local_Language_Ship_To_Account__c != workOrder.SMAX_PS_Local_Language_Ship_To_Account__c ||
								old.SVMXC__Order_Type__c != workOrder.SVMXC__Order_Type__c ||
								old.SVMXC__Billing_Type__c != workOrder.SVMXC__Billing_Type__c ||
								old.SMAX_PS_Override_Malfunction_Start_Date__c != workOrder.SMAX_PS_Override_Malfunction_Start_Date__c
						))
				{
					// SVMXINT-589 Added Account Lookup fields (above)
					// SVMXINT-615 Added the Order / Billing Types (above)
					// SVMXCFG-896 Added Override Malfunction Start Date (above)
					// SVMXCFG-903 Added Local Language BillTo and ShipTo lookups (above)
					iEvent.SMAX_PS_Action__c = 'UPDATE';
					iEvent.SMAX_PS_WorkOrderId__c = workOrder.Id;
					events.add(iEvent);
				}
				else if ( existsSAP && old != null && (
							old.SMAX_PS_Q1_Answer__c != workOrder.SMAX_PS_Q1_Answer__c ||
							old.SMAX_PS_Q2_Answer__c != workOrder.SMAX_PS_Q2_Answer__c ||
							old.SMAX_PS_Q3_Answer__c != workOrder.SMAX_PS_Q3_Answer__c ||
							old.SMAX_PS_Q4_Answer__c != workOrder.SMAX_PS_Q4_Answer__c ||
							old.SMAX_PS_Q5_Answer__c != workOrder.SMAX_PS_Q5_Answer__c
						))
				{
					// SVMXINT-651 When the "Guidance" (aka "Additional Info") Answers change, send new event
					iEvent.SMAX_PS_Action__c = 'GUIDANCE';
					iEvent.SMAX_PS_WorkOrderId__c = workOrder.Id;
					events.add(iEvent);
				}
				else if (existsSAP && old != null
						&& isIntegrationUser && workOrder.CreatedById == UserInfo.getUserId()
						&& old.SMAX_PS_SAP_SystemStatus__c == null && workOrder.SMAX_PS_SAP_SystemStatus__c != null)
				{
					// SVMXINT-605 End of WO Load, send UPDATE even if above logic didnt fire
					iEvent.SMAX_PS_Action__c = 'UPDATE';
					iEvent.SMAX_PS_WorkOrderId__c = workOrder.Id;
					events.add(iEvent);
				}
			}
			System.debug('Events->'+events);
		}

		sendWorkOrderEvents(events);
	}

	// JIRA #387 - Dispatch Console - Duplicate WO Platform Events
	private static Set<Id> WO_EVENT_IDS = new Set<Id>();
	// SVMXCFG-648 Changing to public so we can reuse from Debrief Manager
	public static void sendWorkOrderEvents(List<SMAX_PS_WorkOrder_Event__e> events)
	{
		List<SMAX_PS_WorkOrder_Event__e> filteredEvents = new List<SMAX_PS_WorkOrder_Event__e>();
		for (SMAX_PS_WorkOrder_Event__e evt : events)
		{
			if (!WO_EVENT_IDS.contains(evt.SMAX_PS_WorkOrderId__c))
			{
				filteredEvents.add(evt);
				// Hold on to WO Ids to make sure only 1 Event sent for each
				WO_EVENT_IDS.add(evt.SMAX_PS_WorkOrderId__c);
			}
		}

		SMAX_PS_PlatformEventUtility.publishEvents(filteredEvents, 'SMAX_PS_WorkOrderId__c', 'SMAX_PS_Action__c');
	}

	private static Set<String> PRE_OPEN_STATUS = new Set<String> { 'Initializing', 'On Hold - Cost', 'On Hold - Credit' };
	private static Set<String> NON_DISPATCH_STATUS = new Set<String> { 'Ready for Review', 'Closed', 'Canceled', 'Technician Enroute', 'Technician Onsite', 'Ready to Invoice', 'Work Complete', 'Work Complete - Error', 'DMR Rejected', 'DMR Released', 'Approved', 'HSI', 'Estimate Approved', 'Estimate Rejected', 'Invoiced', 'Submit WO for Approval' };

	/**
	 * Based on updates from SAP, auto-update the WO Order Status.
	 * Should be called in the "before" trigger(s)
	 */
	public static void updateWorkOrderStatus(List<SVMXC__Service_Order__c> woNewList, Map<Id, SVMXC__Service_Order__c> woOldMap)
	{
		if (!SMAX_PS_Utility.isActive('Work Order Update Status', 'Based on updates from SAP, auto-update the WO Order Status.'))
			return;

		RecordType depotRT = SMAX_PS_Utility.getRecordType('SVMXC__Service_Order__c', 'Depot_Repair');
		List<Id> tecoWoIds = new List<Id>();
		if (!woNewList.isEmpty()) {
			for (SVMXC__Service_Order__c workOrder : woNewList)
			{
				SVMXC__Service_Order__c old = (woOldMap == null) ? null : woOldMap.get(workOrder.id);

				if (old != null
						&& workOrder.SVMXC__Order_Status__c != old.SVMXC__Order_Status__c
						&& workOrder.SVMXC__Order_Status__c == 'Initializing'
						&& workOrder.SMAX_PS_SAP_SystemStatus__c != null)
				{
					// Don't allow WO to go back to Initializing if they already have a SAP System Status
					workOrder.SVMXC__Order_Status__c = old.SVMXC__Order_Status__c;
				}

				if ( old != null && (old.SMAX_PS_CreditHold__c != workOrder.SMAX_PS_CreditHold__c
						|| old.SMAX_PS_SAP_SystemStatus__c != workOrder.SMAX_PS_SAP_SystemStatus__c) )
				{
					// SVMXCFG-409 - Only Update Order Status if NOT past "Open" status
					if (PRE_OPEN_STATUS.contains(workOrder.SVMXC__Order_Status__c))
					{
						if (workOrder.SMAX_PS_SAP_SystemStatus__c == 'CRTD')
							workOrder.SVMXC__Order_Status__c = 'On Hold - Cost';
						if (workOrder.SMAX_PS_SAP_SystemStatus__c == 'REL' && workOrder.SMAX_PS_CreditHold__c == true)
							workOrder.SVMXC__Order_Status__c = 'On Hold - Credit';
						if (workOrder.SMAX_PS_SAP_SystemStatus__c == 'REL' && workOrder.SMAX_PS_CreditHold__c == false)
						{
							// SVMXCFG-682 - If Tech already populated, change to 'Assigned' instead
							if (workOrder.SVMXC__Group_Member__c == null)
							{
								workOrder.SVMXC__Order_Status__c = 'Open';
							}
							else
							{
								workOrder.SVMXC__Order_Status__c = 'Assigned';
							}
						}
					}
					if (workOrder.SMAX_PS_SAP_SystemStatus__c == 'TECO')
					{
						tecoWoIds.add(workOrder.Id);
					}
					if (workOrder.SMAX_PS_SAP_SystemStatus__c == 'CLSD' && workOrder.SVMXC__Order_Status__c != 'Canceled')
					{
						workOrder.SVMXC__Order_Status__c = 'Closed';
					}
				}
				else if (old != null && (old.SMAX_PS_DMR_Number__c != workOrder.SMAX_PS_DMR_Number__c))
				{
					workOrder.SVMXC__Order_Status__c = 'Ready for Review';
				}
				// RE-FACTORED WF Rule: SVMX_PS - Set WO to Assigned
				else if (old != null && old.SVMXC__Dispatch_Status__c != workOrder.SVMXC__Dispatch_Status__c
						&& workOrder.SVMXC__Dispatch_Status__c == 'Assigned'
						&& (!NON_DISPATCH_STATUS.contains(workOrder.SVMXC__Order_Status__c)))
				{
					// SVMXCFG-932 - Allow Assignment while "On-Hold - XXX", but do not change to "Assigned"
					if (workOrder.SMAX_PS_SAP_SystemStatus__c == 'CRTD' || workOrder.SMAX_PS_CreditHold__c == true)
					{
						// No action.. do not move to "Assigned"
					}
					else if (workOrder.SMAX_PS_SAP_SystemStatus__c == null && workOrder.RecordTypeId == depotRT.Id)
					{
						// No action... to not move to "Assigned"
					}
					// 2020-01-28 commented out if clause to make sure estimates change to 'Assigned'
					else //if (workOrder.SMAX_PS_SAP_SystemStatus__c != null)
					{
						workOrder.SVMXC__Order_Status__c = 'Assigned';
					}
				}
			}
		}

		if (!tecoWoIds.isEmpty())
		{
			if (!SMAX_PS_Utility.isActive('Update IP Last WO Details', 'Update the Last Work Order Details field on the IP when WO Status changes to Work Complete.'))
				return;

			updateInstalledProductDetails(tecoWoIds);
		}
	}

//    public static Set<String> NON_PRICED_WO_TYPES = new Set<String> { 'Installation', 'Internal' };

	/**
	 *  Update the child Work Detail lines Status to "Submitted" if the "Submit All Lines" field is checked
	 *  Should be called in the "before" trigger(s)
	 *  DEPRECATED as part of One-Click Complete
	 */
/*
    public static void updateWorkDetailLineStatus(List<SVMXC__Service_Order__c> woNewList, Map<Id, SVMXC__Service_Order__c> woOldMap)
    {
        if (!SMAX_PS_Utility.isActive('Work Order Submit All Lines', 'Update the child Work Detail lines Status to "Submitted" if the "Submit All Lines" field is checked'))
            return;

        // Get Record Type Id for Usage Consumption
        Id usageRecTypeId = SMAX_PS_Utility.getRecordType('SVMXC__Service_Order_Line__c', 'UsageConsumption').Id;

        // Collect qualified Work Order Ids
        Map<Id, SVMXC__Service_Order__c> woMap = new Map<Id, SVMXC__Service_Order__c>();
        for (SVMXC__Service_Order__c workOrder : woNewList)
        {
            SVMXC__Service_Order__c old = (woOldMap == null) ? null : woOldMap.get(workOrder.id);
            if ( old != null && old.SMAX_PS_SubmitAllLines__c != workOrder.SMAX_PS_SubmitAllLines__c && workOrder.SMAX_PS_SubmitAllLines__c == TRUE)
            {
                woMap.put(workOrder.Id, workOrder);
                workOrder.SMAX_PS_SubmitAllLines__c=false;
            }
        }
        if (woMap.isEmpty())
            return;
        System.debug('SUBMIT_ALL_LINES Starting');

        // Select the Work Detail lines which qualify for updation
        List<SVMXC__Service_Order_Line__c> wdList = new List<SVMXC__Service_Order_Line__c>([SELECT Id, Name,
            SVMXC__Line_Status__c, SVMXC__Line_Type__c, SVMXC__Service_Order__c,
            SVMXC__Product__c, SMAX_PS_ContractPercentDiscount__c
            FROM SVMXC__Service_Order_Line__c WHERE SVMXC__Service_Order__c in :woMap.keySet() AND RecordTypeId = :usageRecTypeId ]);
            //AND SVMXC__Line_Status__c='Priced']);

        // SVMXCFG-335 WO Submit Lines: Skip Priced on 100% Discount Lines
        Map<Id, List<SVMXC__Service_Order_Line__c>> linesToDiscount = new Map<Id, List<SVMXC__Service_Order_Line__c>>();

        // Update Work Detail Lines Status
        Set<Id> woIdsToSend = new Set<Id>(woMap.keySet());
        List<SVMXC__Service_Order_Line__c> wdToUpdate = new List<SVMXC__Service_Order_Line__c>();
        for ( SVMXC__Service_Order_Line__c wd : wdList ) {
            SVMXC__Service_Order__c wo = woMap.get(wd.SVMXC__Service_Order__c);
            System.debug('SUBMIT_ALL_LINES WO: ' + wo);
            if (wd.SVMXC__Line_Status__c == 'Priced'
                // SVMXINT-469 Complaints: Fault Code Integration Changes (Send Fault Codes only if not Confirmed)
                || (wd.SVMXC__Line_Type__c == 'Fault Code' && wd.SVMXC__Line_Status__c == 'Open')
                // JIRA #392 - Internal / Installation - Skip Priced
                || (NON_PRICED_WO_TYPES.contains(wo.SVMXC__Billing_Type__c) && wd.SVMXC__Line_Status__c == 'Open') )
            {
                // SVMXINT-461 - If line is already Submitted, this won't fire the event.. check first
                if (wd.SVMXC__Line_Status__c != 'Submitted')
                {
                    wd.SVMXC__Line_Status__c='Submitted';
                    wdToUpdate.add(wd);
                    if (woIdsToSend.contains(wd.SVMXC__Service_Order__c))
                    {
                        woIdsToSend.remove(wd.SVMXC__Service_Order__c);
                    }
                }
            }
            else if (wo.SMAX_PS_ContractEntitlement__c != null && wd.SVMXC__Line_Status__c == 'Open'
                && wd.SMAX_PS_ContractPercentDiscount__c == null)
            {
                if (!linesToDiscount.containsKey(wo.Id))
                    linesToDiscount.put(wo.Id, new List<SVMXC__Service_Order_Line__c>());
                linesToDiscount.get(wo.Id).add(wd);
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
                    wdToUpdate.add(wd);
                    if (woIdsToSend.contains(wd.SVMXC__Service_Order__c))
                    {
                        woIdsToSend.remove(wd.SVMXC__Service_Order__c);
                    }
                }
            }
        }

        if (!wdToUpdate.isEmpty())
            update wdToUpdate;

        // Send SUBMIT event if no lines for each woIds...
        if (!woIdsToSend.isEmpty()) {
            List<SMAX_PS_WorkOrder_Event__e> events = new List<SMAX_PS_WorkOrder_Event__e>();
            for (Id woId : woIdsToSend) {
                SMAX_PS_WorkOrder_Event__e iEvent = new SMAX_PS_WorkOrder_Event__e();
                iEvent.SMAX_PS_Action__c = 'SUBMIT';
                iEvent.SMAX_PS_WorkOrderId__c = woId;
                events.add(iEvent);
            }

            SMAX_PS_PlatformEventUtility.publishEvents(events, 'SMAX_PS_WorkOrderId__c', 'SMAX_PS_Action__c');
        }
    }
*/

	/**
	 *  Validate that the Work Order is allowed to transition to Work Complete.
	 *  Should be called in the "before" trigger(s)
	 *  DEPRECATED as part of One-Click Complete
	 */
/*
    public static void addWorkCompleteError(List<SVMXC__Service_Order__c> woNewList, Map<Id, SVMXC__Service_Order__c> woOldMap)
    {
        if (!SMAX_PS_Utility.isActive('Work Order Complete Validations', 'Validate that the Work Order is allowed to transition to Work Complete.'))
            return;

        // Collect qualified Work Order Ids
        Set<Id> woIds = new Set<Id>();
        // SVMXCFG-515: WO "COMPLETE" Event Bug - Only process WOs in "woToUpdate"
        List<SVMXC__Service_Order__c> woToUpdate = new List<SVMXC__Service_Order__c>();
        if (!woNewList.isEmpty()) {
            for (SVMXC__Service_Order__c workOrder : woNewList)
            {
                SVMXC__Service_Order__c old = (woOldMap == null) ? null : woOldMap.get(workOrder.id);
                if ( old != null && old.SVMXC__Order_Status__c != workOrder.SVMXC__Order_Status__c && workOrder.SVMXC__Order_Status__c == WORK_COMPLETE)
                {
                    woIds.add(workOrder.Id);
                    woToUpdate.add(workOrder);
                }
            }
        }
        if (woIds.isEmpty())
            return;

        RecordType usageRecType = SMAX_PS_Utility.getRecordType('SVMXC__Service_Order_Line__c', 'UsageConsumption');

        // Select the Work Detail lines which are not Confirmed or Canceled
        List<SVMXC__Service_Order_Line__c> wdList = new List<SVMXC__Service_Order_Line__c>([SELECT Id, Name, SVMXC__Service_Order__c,
            SVMXC__Line_Type__c, SVMXC__Line_Status__c
            FROM SVMXC__Service_Order_Line__c WHERE SVMXC__Service_Order__c in :woIds
            AND RecordTypeId = :usageRecType.Id AND SVMXC__Line_Status__c!='Canceled']);
        Map<Id, DebriefStats> woMap = new Map<Id, DebriefStats>();

        // Fill Work Order Detail Map
        for (SVMXC__Service_Order_Line__c wd : wdList) {
            if(!woMap.containskey(wd.SVMXC__Service_Order__c)) {
                woMap.put(wd.SVMXC__Service_Order__c, new DebriefStats());
            }
            // SVMXCFG-380 - Fault Code "Required" Rule Changes... load more stats
            DebriefStats stats = woMap.get(wd.SVMXC__Service_Order__c);
            if (wd.SVMXC__Line_Status__c == 'Confirmed')
            {
                if (wd.SVMXC__Line_Type__c == 'Fault Code')
                {
                    stats.confirmedFaultCodeLines++;
                }
                else
                {
                    stats.confirmedDebriefLines++;
                }
            }
            else
            {
                stats.unconfirmedLines++;
            }
        }

        // SVMXCFG-330 - Ignore Attachments (for now)..
        Boolean verifyAttachments = !SMAX_PS_Utility.isActive('Work Complete - Ignore Attachments', 'Indicates if Attachments should be ignored during the Work Complete rules.');
        // Verify Attachments have been submitted also
        Map<Id, List<Attachment>> woAttachMap = new Map<Id, List<Attachment>>();

        // Fill Work Order Attachment Map
        if (verifyAttachments == TRUE)
        {
            List<Attachment> attachList = new List<Attachment>([SELECT Id, Name, Description, ParentId
                FROM Attachment WHERE ParentId in :woIds AND (Description='' OR Description=null)]);
            for (Attachment attach : attachList) {
                if(!woAttachMap.containskey(attach.ParentId)) {
                    woAttachMap.put(attach.ParentId, new List<Attachment>());
                }
                woAttachMap.get(attach.ParentId).add(attach);
            }
        }

        // Main Process - Display the exception error or send events
        List<Id> woIdList = new List<Id>();
        List<SMAX_PS_WorkOrder_Event__e> events = new List<SMAX_PS_WorkOrder_Event__e>();
        for (SVMXC__Service_Order__c wo : woToUpdate)
        {
            wo.SMAX_PS_Completion_Errors__c = null;
            List<String> errorMsgs = new List<String>();
            DebriefStats stats = (woMap.containsKey(wo.Id)) ? woMap.get(wo.Id) : new DebriefStats();
            Integer wdCount = stats.unconfirmedLines;
            if (wdCount > 0)
            {
                errorMsgs.add('All Work Details must first be successfully submitted and confirmed to SAP. There are currently '
                    + wdCount + ' Work Detail(s) that need to be submitted and confirmed.');
            }
            Integer attachCount = (woAttachMap.containsKey(wo.Id)) ? woAttachMap.get(wo.Id).size() : 0;
            if (attachCount > 0)
            {
                errorMsgs.add('All Attachments must first be successfully submitted and confirmed to SAP. There are currently '
                    + attachCount + ' Attachment(s) that need to be submitted and confirmed.');
            }

            // SVMXCFG-366 Complaints: WO Complete Requires Fault Code
            Integer faultCodeCount = stats.confirmedFaultCodeLines;
            if (faultCodeCount == 0)
            {
                // SVMXCFG-380: If 0 Confirmed Debrief Lines, Installation, or TPV skip this..
                if (stats.confirmedDebriefLines == 0 || wo.SMAX_PS_Is_TPV__c == TRUE) // wo.SMAX_PS_Is_Install__c == TRUE ||
                {
                    System.debug('SKIPPING Fault Code Validation because NO Confirmed Lines OR TPV');
                }
                else
                {
                    errorMsgs.add('At least one Fault Code line must be submitted and confirmed when other Debrief lines are confirmed.');
                }
            }

            if (!errorMsgs.isEmpty())
            {
                String errorMsg = 'For a Work Order to transition to "Work Complete", the following must be corrected: ' + errorMsgs;
                // SVMXCFG-327 - Use a Order Status / Message field instead of Apex Errors
                //wo.addError(errorMsg);
                wo.SMAX_PS_Completion_Errors__c = errorMsg;
                wo.SVMXC__Order_Status__c = 'Work Complete - Error';
            }
            else if (wo.SMAX_PS_SAP_SystemStatus__c != 'TECO')
            {
                SMAX_PS_WorkOrder_Event__e iEvent = new SMAX_PS_WorkOrder_Event__e();
                iEvent.SMAX_PS_Action__c = 'COMPLETE';
                iEvent.SMAX_PS_WorkOrderId__c = wo.Id;
                events.add(iEvent);

                woIdList.add(wo.Id);
            }
            else
            {
                // JIRA #391 - Reissue Billing Request (after Rejecting)
                if (isBillable(wo))
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

        SMAX_PS_PlatformEventUtility.publishEvents(events, 'SMAX_PS_WorkOrderId__c', 'SMAX_PS_Action__c');
    }
*/

	/**
	 *  DEPRECATED as part of One-Click Complete
	 */
/*
    public class DebriefStats
    {
        public Integer confirmedDebriefLines { get; set; }
        public Integer confirmedFaultCodeLines { get; set; }
        public Integer unconfirmedLines { get; set; }

        public DebriefStats()
        {
            this.confirmedDebriefLines = 0;
            this.confirmedFaultCodeLines = 0;
            this.unconfirmedLines = 0;
        }
    }
*/

	// JIRA #390 - Don't send Billing Request is Total = $0
	public static Boolean isBillable(SVMXC__Service_Order__c wo)
	{
		// JIRA # 513 (2018-04-23 Maples) Changed to new Rollup Summary Field below - return wo.SMAX_PS_Is_Billable__c == TRUE && wo.SVMXC__Total_Work_Order_Cost__c > 0.00;
		//return wo.SMAX_PS_Is_Billable__c == TRUE && wo.SMAX_PS_Work_Order_Amount__c > 0.00;
		// SVMXCFG-576 - Changed (again) to now include EITHER total cost with OR without adjustments > 0
		return wo.SMAX_PS_Is_Billable__c == TRUE &&
				(wo.SMAX_PS_Work_Order_Amount__c > 0.00 || wo.SMAX_PS_TotalCalculatedAmount__c > 0.00);
	}

	public static void updateInstalledProductDetails(List<Id> woIds)
	{
		List<SVMXC__Service_Order__c> woList = [SELECT Id, Name, SVMXC__Component__c, SVMXC__Group_Member__r.Name, SVMXC__Order_Type__c, SVMXC__Completed_Date_Time__c
		FROM SVMXC__Service_Order__c WHERE Id IN :woIds];
		Map<Id, SVMXC__Installed_Product__c> ipMap = new Map<Id, SVMXC__Installed_Product__c>();
		for (SVMXC__Service_Order__c wo : woList)
		{
			if (wo.SVMXC__Component__c != null)
			{
				SVMXC__Installed_Product__c ip = new SVMXC__Installed_Product__c();
				ip.Id = wo.SVMXC__Component__c;
				ip.SMAX_PS_Last_Work_Order_Details__c = wo.Name + ', '
						+ wo.SVMXC__Group_Member__r.Name + ', '
						+ wo.SVMXC__Order_Type__c + ', '
						+ wo.SVMXC__Completed_Date_Time__c;
				if (ip.SMAX_PS_Last_Work_Order_Details__c.length() > 255)
					ip.SMAX_PS_Last_Work_Order_Details__c = ip.SMAX_PS_Last_Work_Order_Details__c.substring(0, 252) + '...';
				ipMap.put(ip.Id, ip);
			}
		}
		if (!ipMap.isEmpty())
			update ipMap.values();
	}

	/**
	 *  Work Orders must have a Location, Product or Installed Product.
	 *  Should be called in the "before" trigger(s)
	 */
	public static void preventInvalidWorkOrders(List<SVMXC__Service_Order__c> woNewList)
	{
		if (!SMAX_PS_Utility.isActive('Work Order Prevent Invalid', 'Work Orders must have a Location, Product or Installed Product.'))
			return;

		RecordType fsRecType = SMAX_PS_Utility.getRecordType('SVMXC__Service_Order__c', 'Field_Service');

		// JIRA #385 - Prevent Invalid WO
		for (SVMXC__Service_Order__c wo : woNewList)
		{
			if (wo.SVMXC__Component__c == null && wo.SVMXC__Site__c == null && wo.SVMXC__Product__c == null
					&& (fsRecType != null && fsRecType.Id == wo.RecordTypeId))
			{
				// If all 3 of these are blank, this is an invalid WO.. add an error
				wo.addError('Work Orders must have a Location, Product or Installed Product.');
			}
		}
	}

	/**
	 *  SVMXINT-502: Create Int Errors to detect duplicate processing
	 *  Should be called from WO After Update trigger
	 */
	public static void logDuplicateErrors(List<SVMXC__Service_Order__c> woList, Map<Id, SVMXC__Service_Order__c> oldMap)
	{
		if (!SMAX_PS_Utility.isActive('Work Order Dulicate Errors', 'Create Integration Errors when SAP Confirmation Numbers are changed.'))
			return;

		List<SMAX_PS_IntegrationError__c> errorList = new List<SMAX_PS_IntegrationError__c>();
		for (SVMXC__Service_Order__c wo : woList)
		{
			SVMXC__Service_Order__c old = (oldMap == null) ? null : oldMap.get(wo.Id);
			if (old == null)
				continue;

			if (old.SVMX_PS_External_ID__c != null && wo.SVMX_PS_External_ID__c != old.SVMX_PS_External_ID__c)
			{
				SMAX_PS_IntegrationError__c ie = new SMAX_PS_IntegrationError__c();
				ie.SMAX_PS_RelatedElementType__c = 'WorkOrderId';
				ie.SMAX_PS_RelatedElementIdentifier__c = wo.Id;
				ie.SMAX_PS_ErrorMessage__c = 'DUPLICATE PROCESSING: Work Order posted as multiple SAP Service Order Numbers: '
						+ old.SVMX_PS_External_ID__c + ', ' + wo.SVMX_PS_External_ID__c;
				errorList.add(ie);
			}
			if (old.SMAX_PS_SAP_Notification_ID__c != null && wo.SMAX_PS_SAP_Notification_ID__c != old.SMAX_PS_SAP_Notification_ID__c)
			{
				SMAX_PS_IntegrationError__c ie = new SMAX_PS_IntegrationError__c();
				ie.SMAX_PS_RelatedElementType__c = 'WorkOrderId';
				ie.SMAX_PS_RelatedElementIdentifier__c = wo.Id;
				ie.SMAX_PS_ErrorMessage__c = 'DUPLICATE PROCESSING: Work Order posted as multiple SAP Notification Numbers: '
						+ old.SMAX_PS_SAP_Notification_ID__c + ', ' + wo.SMAX_PS_SAP_Notification_ID__c;
				errorList.add(ie);
			}
		}

		if (!errorList.isEmpty())
			insert errorList;
	}

	// Added for [SVMXCFG-777] - Auto-Fill the Translation lookup based ont he WO Country
	public static void lookupTranslation(List<SVMXC__Service_Order__c> woList, Map<Id, SVMXC__Service_Order__c> oldMap)
	{
		if (!SMAX_PS_Utility.isActive('Work Order Lookup Translation', 'Lookup a Translation record based on the WO Country.'))
			return;

		List<SVMXC__Service_Order__c> woToLookup = new List<SVMXC__Service_Order__c>();
		Set<String> countryCodes = new Set<String>();
		for (SVMXC__Service_Order__c wo : woList)
		{
			if (wo.SVMXC__Country__c != null && wo.SMAX_PS_Translation__c == null)
			{
				woToLookup.add(wo);
				countryCodes.add(wo.SVMXC__Country__c);
			}
		}

		if (countryCodes.isEmpty())
			return;

		Map<String, SMAX_PS_Translation__c> translationMap = new Map<String, SMAX_PS_Translation__c>();
		for (SMAX_PS_Translation__c translation : [SELECT Id, Name, SMAX_PS_Country__c
		FROM SMAX_PS_Translation__c WHERE SMAX_PS_Country__c IN :countryCodes])
		{
			translationMap.put(translation.SMAX_PS_Country__c, translation);
		}

		for (SVMXC__Service_Order__c wo : woToLookup)
		{
			SMAX_PS_Translation__c translation = translationMap.get(wo.SVMXC__Country__c);
			if (translation != null)
			{
				wo.SMAX_PS_Translation__c = translation.Id;
			}
		}
	}

	// Added for [SVMXCFG-837] - Change OrderStatus to 'Open' when Tech is unassigned (and not already complete)
	public static void unassignWO(List<SVMXC__Service_Order__c> woList, Map<Id, SVMXC__Service_Order__c> oldMap)
	{
		for (SVMXC__Service_Order__c wo : woList)
		{
			SVMXC__Service_Order__c old = (oldMap == null) ? null : oldMap.get(wo.Id);
			if (old != null && wo.SVMXC__Group_Member__c == null && old.SVMXC__Group_Member__c != null)
			{
				// UNASSIGN detected...
				if (wo.SVMXC__Order_Status__c == 'Assigned' || wo.SVMXC__Order_Status__c.startsWith('Technician'))
				{
					wo.SVMXC__Order_Status__c = 'Open';
				}
			}
		}
	}

	// ITSFDC-509 When WO is changed to "Depot" OR is "Depot" and gets a SAP Id... auto-create RMA
	public static void autoCreateRMA(List<SVMXC__Service_Order__c> woList, Map<Id, SVMXC__Service_Order__c> oldMap)
	{
		if (!SMAX_PS_Utility.isActive('Work Order Auto Create RMA', 'When WO is changed to "Depot" OR is "Depot" and gets a SAP Id... auto-create RMA.'))
			return;

		Map<Id, SVMXC__Service_Order__c> depotWorkOrders = new Map<Id, SVMXC__Service_Order__c>();
		RecordType depotRT = SMAX_PS_Utility.getRecordType('SVMXC__Service_Order__c', 'Depot_Repair');
		RecordType rmaRT = SMAX_PS_Utility.getRecordType('SVMXC__RMA_Shipment_Order__c', 'RMA');
		RecordType rmaLineRT = SMAX_PS_Utility.getRecordType('SVMXC__RMA_Shipment_Line__c', 'RMA');

		for (SVMXC__Service_Order__c wo : woList)
		{
			SVMXC__Service_Order__c old = (oldMap == null) ? null : oldMap.get(wo.Id);
			if (wo.RecordTypeId == depotRT.Id && wo.SVMX_PS_External_ID__c != null
				&& (old == null || old.RecordTypeId != wo.RecordTypeId || wo.SVMX_PS_External_ID__c != old.SVMX_PS_External_ID__c))
			{
				depotWorkOrders.put(wo.Id, wo);
			}
		}

		if (depotWorkOrders.isEmpty())
		{
			return;
		}

		// Check for pre-existing RMA (if found, stop)
		List<SVMXC__RMA_Shipment_Order__c> existingRMAs = [SELECT Id, Name, SVMXC__Service_Order__c
			FROM SVMXC__RMA_Shipment_Order__c
			WHERE SVMXC__Service_Order__c IN :depotWorkOrders.keySet() AND RecordTypeId = :rmaRT.Id];

		Map<Id, SVMXC__Service_Order__c> woDetailMap = new Map<Id, SVMXC__Service_Order__c>([SELECT Id, Name,
				SVMXC__Site__c, SVMXC__Site__r.SVMXC__Street__c, SVMXC__Site__r.SVMXC__City__c,
				SVMXC__Site__r.SVMXC__State__c, SVMXC__Site__r.SVMXC__Country__c, SVMXC__Site__r.SVMXC__Zip__c,
				SVMXC__Group_Member__c, SVMXC__Group_Member__r.SVMXC__Street__c, SVMXC__Group_Member__r.SVMXC__City__c,
				SVMXC__Group_Member__r.SVMXC__State__c, SVMXC__Group_Member__r.SVMXC__Country__c, SVMXC__Group_Member__r.SVMXC__Zip__c,
				SVMXC__Group_Member__r.SVMXC__Role__c, SVMXC__Group_Member__r.Name, SVMXC__Group_Member__r.SMAX_PS_Work_Center__c
			FROM SVMXC__Service_Order__c WHERE Id IN :depotWorkOrders.keySet()]);

		List<SVMXC__RMA_Shipment_Order__c> rmaList = new List<SVMXC__RMA_Shipment_Order__c>();
		for (SVMXC__Service_Order__c wo : depotWorkOrders.values())
		{
			SVMXC__RMA_Shipment_Order__c woRMA = null;
			for (SVMXC__RMA_Shipment_Order__c rma : existingRMAs)
			{
				if (rma.SVMXC__Service_Order__c == wo.Id)
				{
					woRMA = rma;
					break;
				}
			}

			if (woRMA == null)
			{
				SVMXC__Service_Order__c woDetail = woDetailMap.get(wo.Id);

				// Didn't find one, so auto-create one...
				woRMA = new SVMXC__RMA_Shipment_Order__c();
				woRMA.RecordTypeId = rmaRT.Id;
				woRMA.SVMXC__Service_Order__c = wo.Id;
				woRMA.SVMXC__Company__c = wo.SVMXC__Company__c;
				woRMA.SMAX_PS_ShipTo__c = wo.SMAX_PS_ShipTo__c;
				woRMA.SVMXC__Order_Status__c = 'Open';
				woRMA.SVMXC__Order_Type__c = 'Return';
				woRMA.SVMXC__RMA_Type__c = 'Instrument';
				woRMA.SMAX_PS_Requested_Delivery_Date__c = wo.SVMXC__Scheduled_Date__c;

				// Map the Source (From) fields from the Location...
				woRMA.SVMXC__Source_Location__c = wo.SVMXC__Site__c;
				SVMXC__Site__c loc = (woDetail != null) ? woDetail.SVMXC__Site__r : null;
				if (loc != null)
				{
					woRMA.SVMXC__Source_Street__c = loc.SVMXC__Street__c;
					woRMA.SVMXC__Source_City__c = loc.SVMXC__City__c;
					woRMA.SVMXC__Source_State__c = loc.SVMXC__State__c;
					woRMA.SVMXC__Source_Zip__c = loc.SVMXC__Zip__c;
					woRMA.SVMXC__Source_Country__c = loc.SVMXC__Country__c;
				}

				// Map the Destination (To) fields from the "Depot Queue" Technician
				SVMXC__Service_Group_Members__c tech = (woDetail != null) ? woDetail.SVMXC__Group_Member__r : null;
				if (tech != null && tech.SVMXC__Role__c == 'Depot Queue')
				{
					woRMA.SVMXC__Warehouse__c = tech.Name + ' [' + tech.SMAX_PS_Work_Center__c + ']';
					woRMA.SVMXC__Destination_Street__c = tech.SVMXC__Street__c;
					woRMA.SVMXC__Destination_City__c = tech.SVMXC__City__c;
					woRMA.SVMXC__Destination_State__c = tech.SVMXC__State__c;
					woRMA.SVMXC__Destination_Zip__c = tech.SVMXC__Zip__c;
					woRMA.SVMXC__Destination_Country__c = tech.SVMXC__Country__c;
				}

				rmaList.add(woRMA);
			}
		}

		if (rmaList.isEmpty())
		{
			return;
		}

		insert rmaList;

		List<SVMXC__RMA_Shipment_Line__c> rmaLines = new List<SVMXC__RMA_Shipment_Line__c>();
		for (SVMXC__RMA_Shipment_Order__c rma : rmaList)
		{
			// Create lines & then update to "Submitted to ERP"
			SVMXC__Service_Order__c wo = depotWorkOrders.get(rma.SVMXC__Service_Order__c);

			SVMXC__RMA_Shipment_Line__c rmaLine = new SVMXC__RMA_Shipment_Line__c();
			rmaLine.SVMXC__RMA_Shipment_Order__c = rma.Id;
			rmaLine.SVMXC__Expected_Quantity2__c = 1;
			rmaLine.SVMXC__Serial_Number__c = wo.SVMXC__Component__c;
			rmaLine.SVMXC__Product__c = wo.SVMXC__Product__c;
			rmaLine.BD_Return_Part_Number__c = wo.BD_Equipment_Part_Return_Number__c;
			rmaLine.RecordTypeId = rmaLineRT.Id;
			rmaLines.add(rmaLine);

			rma.SVMXC__Order_Status__c = 'Submitted to ERP';
		}

		insert rmaLines;

		update rmaList;
	}

	public static void updateRollups(List<SVMXC__Service_Order__c> woList, Map<Id, SVMXC__Service_Order__c> oldMap)
	{
		if (!SMAX_PS_Utility.isActive('Work Order Rollups', 'Update the WO header with child counts / details'))
			return;

		Map<Id, SVMXC__Service_Order__c> woDetails = new Map<Id, SVMXC__Service_Order__c>([SELECT Id, Name,
			//(SELECT Id, Name, BD_Eligible_for_Return__c FROM SVMXC__Service_Order_Line__r WHERE BD_Eligible_for_Return__c = TRUE)
			(SELECT Id, Name, BD_Covered_Until__c FROM Extended_Warranty_Coverages__r
				WHERE BD_Covered_Until__c > TODAY AND BD_Warranty_Work_Order__c = null)
			FROM SVMXC__Service_Order__c WHERE Id IN :woList]);

		for (SVMXC__Service_Order__c wo : woList)
		{
			// Number of Extended Warranty Parts
			SVMXC__Service_Order__c woDetail = woDetails.get(wo.Id);
			Integer numEWP = (woDetail == null || woDetail.Extended_Warranty_Coverages__r == null)
					? 0 : woDetail.Extended_Warranty_Coverages__r.size();
			wo.BD_Number_of_Extended_Warranty_Parts__c = numEWP;
		}
	}


}