/*
	Test Class for  SMAX_PS_WorkOrderManager
	Client      :   PerkinElmer
	Created by  :   Veerendra on 2017-10-11
*/
@isTest(seeAllData=false)
public class SMAX_PS_WorkOrder_UT
{
	static testMethod void createWorkOrderTestData()
	{
		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001','GB');
		Map<String, Account> acctMap = SMAX_PS_TestDataFactory.createTestPartnerAccounts(acct);

		Contact cont = SMAX_PS_TestDataFactory.createTestContact('Sir', 'Testalot', acct, 'TESTX00000001A');
		Product2 pd = SMAX_PS_TestDataFactory.createTestProduct('TestProduct', '106018','TST');
		pd.SMAX_PS_Super_Business_Unit__c = 'DAS';
		update pd;

		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct,'TestLocationSite', '121212','LOC123');
		loc.SMAX_PS_MaintenancePlant__c = 'TT12';
		// SVMXCFG-903 Copy Local Language Accounts to WO
		loc.SMAX_PS_LL_BillToExtID__c = acctMap.get('LocalLangBillTo').PKI_SAP_Customer_Number__c;
		loc.SMAX_PS_LL_ShipToExtID__c = acctMap.get('LocalLangShipTo').PKI_SAP_Customer_Number__c;
		update loc;

		SVMXC__Site__c expLoc = SMAX_PS_TestDataFactory.createTestLocation(acct,'Test Expense Loc', 'TT12F000', 'LOC123');

		Product2 laborProd = SMAX_PS_TestDataFactory.createTestProduct('TestLabor', 'LAB100101', 'LABR', 'Labor');
		Product2 travelProd = SMAX_PS_TestDataFactory.createTestProduct('TestTravel', 'TRV10011', 'TRVL', 'Travel');

		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('123456',acct,loc,'5545333',pd);

		// Insert Work Order
		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createWO(ip, cont);

		SVMXC__Service_Order__c result = [SELECT Id, Name, SMAX_PS_Super_Business_Unit__c FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.assertEquals(pd.SMAX_PS_Super_Business_Unit__c, result.SMAX_PS_Super_Business_Unit__c);

		wo.SVMX_PS_External_ID__c = 'SO001991992';
		wo.SMAX_PS_SAP_SystemStatus__c = 'CRTD';
		update wo;

		wo.SMAX_PS_SAP_SystemStatus__c = 'REL';
		wo.SMAX_PS_CreditHold__c = true;
		update wo;

		wo.SMAX_PS_SAP_SystemStatus__c = 'REL';
		wo.SMAX_PS_CreditHold__c = false;
		update wo;

		Test.startTest();

		//Id wDetailUsageConsumptionRecordTypeId = Schema.SObjectType.SVMXC__Service_Order_Line__c.getRecordTypeInfosByName().get('Usage/Consumption').getRecordTypeId();
		//SVMXC__Service_Order_Line__c wd = new SVMXC__Service_Order_Line__c(
		//					SVMXC__Service_Order__c=wo.Id,
		//					RecordTypeId=wDetailUsageConsumptionRecordTypeId,
		//					SVMXC__Line_Status__c='Confirmed');
		//insert wd;
		Id usage = Schema.SObjectType.SVMXC__Service_Order_Line__c.getRecordTypeInfosByName().get('Usage/Consumption').getRecordTypeId();
		SVMXC__Service_Order_Line__c laborLine = new SVMXC__Service_Order_Line__c(
			SVMXC__Service_Order__c=wo.Id, RecordTypeId=usage, SVMXC__Line_Type__c = 'Labor', SVMXC__Line_Status__c='Confirmed',
			SVMXC__Product__c = laborProd.Id, SVMXC__Actual_Quantity2__c = 1.5);
		SVMXC__Service_Order_Line__c travelLine = new SVMXC__Service_Order_Line__c(
			SVMXC__Service_Order__c=wo.Id, RecordTypeId=usage, SVMXC__Line_Type__c = 'Travel', SVMXC__Line_Status__c='Confirmed',
			SVMXC__Product__c = travelProd.Id, SVMXC__Actual_Quantity2__c = 2);
		List<SVMXC__Service_Order_Line__c> lines = new List<SVMXC__Service_Order_Line__c> { laborLine, travelLine };
		insert lines;

		wo.SVMXC__Scheduled_Date__c = Date.today().addDays(2);
		wo.SMAX_PS_SubmitAllLines__c = TRUE;
		update wo;

		wo.SVMXC__Order_Status__c='Work Complete';
		update wo;

		// Should fail.. No Fault Lines..
		result = [SELECT Id, Name, SVMXC__Order_Status__c FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.assertEquals('Work Complete - Error', result.SVMXC__Order_Status__c);
		for (SVMXC__Service_Order_Line__c line : lines)
			line.SVMXC__Line_Status__c = 'Canceled';
		update lines;

		wo = new SVMXC__Service_Order__c();
		wo.Id = result.Id;
		wo.SVMXC__Order_Status__c='Work Complete';
		update wo;

		result = [SELECT Id, Name, SVMXC__Order_Status__c, SMAX_PS_Completion_Errors__c FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.assertEquals(null, result.SMAX_PS_Completion_Errors__c);
		System.assertEquals('Work Complete', result.SVMXC__Order_Status__c);

		wo.SMAX_PS_SAP_SystemStatus__c='TECO';
		update wo;

		wo.SMAX_PS_DMR_Number__c = 'TST11001001';
		update wo;

		wo.SMAX_PS_SAP_SystemStatus__c = 'CLSD';
		update wo;

		Test.stopTest();
	}

	static testMethod void workOrderDuplicateTest()
	{
		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001','GB');
		Contact cont = SMAX_PS_TestDataFactory.createTestContact('Sir', 'Testalot', acct, 'TESTX00000001A');
		Product2 pd = SMAX_PS_TestDataFactory.createTestProduct('TestProduct', '106018','TST');
		pd.SMAX_PS_Super_Business_Unit__c = 'DAS';
		update pd;

		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct,'TestLocationSite', '121212','LOC123');
		loc.SMAX_PS_MaintenancePlant__c = 'TT12';
		update loc;

		SVMXC__Site__c expLoc = SMAX_PS_TestDataFactory.createTestLocation(acct,'Test Expense Loc', 'TT12F000', 'LOC123');

		Product2 laborProd = SMAX_PS_TestDataFactory.createTestProduct('TestLabor', 'LAB100101', 'LABR', 'Labor');

		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('123456',acct,loc,'5545333',pd);

		// Insert Work Order
		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createWO(ip, cont);

		SVMXC__Service_Order__c result = [SELECT Id, Name, SMAX_PS_Super_Business_Unit__c FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.assertEquals(pd.SMAX_PS_Super_Business_Unit__c, result.SMAX_PS_Super_Business_Unit__c);

		Id usage = Schema.SObjectType.SVMXC__Service_Order_Line__c.getRecordTypeInfosByName().get('Usage/Consumption').getRecordTypeId();
		SVMXC__Service_Order_Line__c laborLine = new SVMXC__Service_Order_Line__c(
			SVMXC__Service_Order__c=wo.Id, RecordTypeId=usage, SVMXC__Line_Type__c = 'Labor', SVMXC__Line_Status__c='Submitted',
			SVMXC__Product__c = laborProd.Id, SVMXC__Actual_Quantity2__c = 1.5);
		List<SVMXC__Service_Order_Line__c> lines = new List<SVMXC__Service_Order_Line__c> { laborLine };
		insert lines;

		Test.startTest();

		wo.SVMX_PS_External_ID__c = 'SO001991992';
		wo.SMAX_PS_SAP_Notification_ID__c = 'NO0019291293';
		wo.SMAX_PS_SAP_SystemStatus__c = 'CRTD';
		update wo;

		List<SMAX_PS_IntegrationError__c> errors = [SELECT Id, Name FROM SMAX_PS_IntegrationError__c WHERE SMAX_PS_WorkOrder__c = :wo.Id];
		System.assertEquals(0, errors.size());

		wo.SVMX_PS_External_ID__c = 'SO001991111';
		wo.SMAX_PS_SAP_Notification_ID__c = 'NO0019291111';
		update wo;

		errors = [SELECT Id, Name FROM SMAX_PS_IntegrationError__c WHERE SMAX_PS_WorkOrder__c = :wo.Id];
		System.assertEquals(2, errors.size());

		laborLine.SMAX_PS_SAP_Confirmation__c = 'WD112233';
		update laborLine;

		List<SMAX_PS_IntegrationError__c> lineErrors = [SELECT Id, Name FROM SMAX_PS_IntegrationError__c WHERE SMAX_PS_WorkDetail__c = :laborLine.Id];
		System.assertEquals(0, lineErrors.size());

		laborLine.SMAX_PS_SAP_Confirmation__c = 'WD112244';
		update laborLine;

		lineErrors = [SELECT Id, Name FROM SMAX_PS_IntegrationError__c WHERE SMAX_PS_WorkDetail__c = :laborLine.Id];
		System.assertEquals(1, lineErrors.size());

		laborLine.SMAX_PS_CancellationNumber__c = '332211DW';
		update laborLine;

		laborLine.SMAX_PS_CancellationNumber__c = '442211DW';
		update laborLine;

		lineErrors = [SELECT Id, Name FROM SMAX_PS_IntegrationError__c WHERE SMAX_PS_WorkDetail__c = :laborLine.Id];
		System.assertEquals(2, lineErrors.size());

		Test.stopTest();
	}

	static testMethod void createInvalidWorkOrder()
	{
		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001','GB');
		Contact cont = SMAX_PS_TestDataFactory.createTestContact('Sir', 'Testalot', acct, 'TESTX00000001A');

		RecordType fsRecType = SMAX_PS_Utility.getRecordType('SVMXC__Service_Order__c', 'Field_Service');
		RecordType rmRecType = SMAX_PS_Utility.getRecordType('SVMXC__Service_Order__c', 'Remote');

		SVMXC__Service_Order__c fsWO = new SVMXC__Service_Order__c(RecordTypeId = fsRecType.Id,
			SVMXC__Company__c = acct.Id, SVMXC__Contact__c = cont.Id,
			SMAX_PS_SAP_SystemStatus__c='TECO', SVMX_PS_External_ID__c = 'SAP100299345', SMAX_PS_SAP_Notification_ID__c = 'NOT1002993');
		Database.SaveResult result1 = Database.insert(fsWO, false);
		System.debug('WO1 ERRORS: ' + result1.getErrors());
		System.assertEquals(false, result1.isSuccess());

		SVMXC__Service_Order__c rmWO = new SVMXC__Service_Order__c(RecordTypeId = rmRecType.Id,
			SVMXC__Company__c = acct.Id, SVMXC__Contact__c = cont.Id,
			SMAX_PS_SAP_SystemStatus__c='TECO', SVMX_PS_External_ID__c = 'SAP100299345R', SMAX_PS_SAP_Notification_ID__c = 'NOT1002993R');
		Database.SaveResult result2 = Database.insert(rmWO, false);
		System.debug('WO2 ERRORS: ' + result2.getErrors());
		System.assertEquals(true, result2.isSuccess());
	}

	static testMethod void testForceIntegration()
	{
		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001','GB');
		Contact cont = SMAX_PS_TestDataFactory.createTestContact('Sir', 'Testalot', acct, 'TESTX00000001A');
		Product2 pd = SMAX_PS_TestDataFactory.createTestProduct('TestProduct', '106018','MFT');
		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct,'TestLocationSite', '121212','LOC123');
		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('123456',acct,loc,'5545333',pd);
		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createWO(ip, cont);

		wo.SMAX_PS_ForceIntegration__c = TRUE;
		update wo;

		wo.SVMX_PS_External_ID__c = 'SO001991992';
		wo.SMAX_PS_ForceIntegration__c = TRUE;
		update wo;

		wo.SMAX_PS_SAP_SystemStatus__c = 'TECO';
		wo.SMAX_PS_ForceIntegration__c = TRUE;
		update wo;
	}

	static testMethod void testSubmitWithoutPrice()
	{
		// SVMXCFG-335 WO Submit Lines: Skip Priced on 100% Discount Lines
		String modelSeries = 'TST001';
		String locCode = 'TSTC01';

		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001');
		Contact c = SMAX_PS_TestDataFactory.createTestContact('Testie', 'Testerson', acct, 'TEST000000101');
		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct, 'Test Location', 'TESTLOC001', locCode);
		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('TESTX0000234001', acct, loc, modelSeries);

		Product2 laborProd = SMAX_PS_TestDataFactory.createTestProduct('TestLabor', 'LAB10010', 'LABR', 'Labor');
		Product2 travelProd = SMAX_PS_TestDataFactory.createTestProduct('TestTravel', 'TRV10010', 'TRVL', 'Travel');
		Product2 svcPartsProd = SMAX_PS_TestDataFactory.createTestProduct('TestSvcPart', 'SVP10010', 'GC', 'Service Parts');

		Date startDate = System.today();
		Date endDate = startDate.addMonths(12);
		SVMXC__Service_Contract__c sc = SMAX_PS_TestDataFactory.createSvcMaintContract('TestServiceContract', ip.SVMXC__Company__c, startDate, endDate);
		SVMXC__Service_Contract__c item = SMAX_PS_TestDataFactory.createContractItem(sc, 'TestServiceContract', startDate, endDate);
		SVMXC__Service_Contract_Products__c cp = SMAX_PS_TestDataFactory.createCoveredIP(item, startDate, endDate, ip);
		SVMXC__Service_Contract_Services__c ent = SMAX_PS_TestDataFactory.createEntitlement(item,'REP', 0, 0);
		ent.SMAX_PS_ServicePartsDiscountCovered__c = 100;
		update ent;

		SMAX_PS_Fault_Code__c fc = SMAX_PS_TestDataFactory.createTestFaultCode('TFAM', 'TFAM-TTT', 'TTT2', 'Testing', TRUE);

		Test.startTest();

		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createContractWO(ip, c);

		SVMXC__Service_Order__c result = [SELECT Id, Name, SVMXC__Service_Contract__c, SMAX_PS_ContractItem__c,
			SMAX_PS_ContractEntitlement__c, SMAX_PS_CoveredProduct__c, SVMXC__Auto_Entitlement_Status__c, SVMXC__Is_Entitlement_Performed__c
			FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];

		Id usage = Schema.SObjectType.SVMXC__Service_Order_Line__c.getRecordTypeInfosByName().get('Usage/Consumption').getRecordTypeId();
		SVMXC__Service_Order_Line__c laborLine = new SVMXC__Service_Order_Line__c(
			SVMXC__Service_Order__c=wo.Id, RecordTypeId=usage, SVMXC__Line_Type__c = 'Labor', SVMXC__Line_Status__c='Open',
			SVMXC__Product__c = laborProd.Id, SVMXC__Actual_Quantity2__c = 1.5);
		SVMXC__Service_Order_Line__c travelLine = new SVMXC__Service_Order_Line__c(
			SVMXC__Service_Order__c=wo.Id, RecordTypeId=usage, SVMXC__Line_Type__c = 'Travel', SVMXC__Line_Status__c='Open',
			SVMXC__Product__c = travelProd.Id, SVMXC__Actual_Quantity2__c = 2);
		SVMXC__Service_Order_Line__c svcPartsLine = new SVMXC__Service_Order_Line__c(
			SVMXC__Service_Order__c=wo.Id, RecordTypeId=usage, SVMXC__Line_Type__c = 'Parts', SVMXC__Line_Status__c='Open',
			SVMXC__Product__c = svcPartsProd.Id, SVMXC__Actual_Quantity2__c = 1);
		SVMXC__Service_Order_Line__c fcl = new SVMXC__Service_Order_Line__c(
			SVMXC__Service_Order__c=wo.Id, RecordTypeId=usage, SVMXC__Line_Type__c = 'Fault Code', SVMXC__Line_Status__c='Open',
			SMAX_PS_Fault_Code__c = fc.Id); //, SMAX_PS_ActionFaultCode__c = fc.Id, SMAX_PS_InstallationFaultCode__c = fc.Id, SMAX_PS_CompletionFaultCode__c = fc.Id);
		List<SVMXC__Service_Order_Line__c> lines = new List<SVMXC__Service_Order_Line__c> { laborLine, travelLine, svcPartsLine, fcl };
		insert lines;

		wo.SMAX_PS_SubmitAllLines__c = TRUE;
		update wo;

		Test.stopTest();

		List<SVMXC__Service_Order_Line__c> results = [SELECT Id, Name, SVMXC__Line_Status__c, SVMXC__Line_Type__c, SMAX_PS_ContractPercentDiscount__c
			FROM SVMXC__Service_Order_Line__c WHERE Id IN :lines];
		for (SVMXC__Service_Order_Line__c line : results)
		{
			System.assertEquals('Submitted', line.SVMXC__Line_Status__c);
			if (line.SVMXC__Line_Type__c != 'Fault Code')
				System.assertEquals(100, line.SMAX_PS_ContractPercentDiscount__c);
		}
	}


	static testMethod void testComplaints()
	{   
		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001','GB');
		Contact cont = SMAX_PS_TestDataFactory.createTestContact('Sir', 'Testalot', acct, 'TESTX00000001A');
		Product2 pd = SMAX_PS_TestDataFactory.createTestProduct('TestProduct', '106018','MFT');
		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct,'TestLocationSite', '121212','LOC123');

		SVMXC__Site__c expLoc = SMAX_PS_TestDataFactory.createTestLocation(acct,'Test Expense Loc', 'TT12F000', 'LOC123');

		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('123456',acct,loc,'5545333',pd);
		ip.SMAX_PS_CatalogProfile__c = 'TCP';
		update ip;
		SMAX_PS_HSI_Settings__c hsi = SMAX_PS_TestDataFactory.createHSICustomSetting('GB','MFT');  // Should force HSI rules

		// Fault Code data
		SMAX_PS_Catalog_Profile__c catProf = new SMAX_PS_Catalog_Profile__c(Name = 'TCP',
			SMAX_PS_Catalog_Profile__c = 'TCP', SMAX_PS_Code_Family__c = 'TFAM');
		insert catProf;

		SMAX_PS_Fault_Code__c fc = SMAX_PS_TestDataFactory.createTestFaultCode('TFAM', 'TFAM-TTT', 'TTT2', 'Testing', TRUE);

		Test.startTest();

		// Insert Work Order
		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createWO(ip, cont);

		SVMXC__Service_Order__c hsiWO = [SELECT Id, Name, SVMXC__Order_Status__c, SMAX_PS_HSI_Required__c, SMAX_PS_ShipTo__c, SVMXC__Component__c FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.debug('WO COMPLAINTS: HSI WO = ' + hsiWO);
		System.assertEquals('HSI', hsiWO.SVMXC__Order_Status__c);
		System.assertEquals(true, hsiWO.SMAX_PS_HSI_Required__c);

		wo.SMAX_PS_HSI1_Answer__c = 'No';
		wo.SMAX_PS_HSI2_Answer__c = 'Unknown';
		wo.SMAX_PS_HSI3_Answer__c = 'Yes';
		wo.SVMXC__Order_Status__c = 'Initializing';
		update wo;

		wo.SVMX_PS_External_ID__c = 'SO001991993';
		wo.SMAX_PS_SAP_SystemStatus__c = 'REL';
		update wo;

		// Add Fault Code line
		Id wDetailUsageConsumptionRecordTypeId = Schema.SObjectType.SVMXC__Service_Order_Line__c.getRecordTypeInfosByName().get('Usage/Consumption').getRecordTypeId();
		SVMXC__Service_Order_Line__c fcl = new SVMXC__Service_Order_Line__c(
			SVMXC__Service_Order__c=wo.Id, RecordTypeId=wDetailUsageConsumptionRecordTypeId, SVMXC__Line_Type__c = 'Fault Code', SVMXC__Line_Status__c='Confirmed',
			SMAX_PS_Fault_Code__c = fc.Id); //, SMAX_PS_ActionFaultCode__c = fc.Id, SMAX_PS_InstallationFaultCode__c = fc.Id, SMAX_PS_CompletionFaultCode__c = fc.Id);
		insert fcl;

		wo.SVMXC__Priority__c = 'X'; // Manual Complaint
		update wo;

		SVMXC__Service_Order__c complaintWO = [SELECT Id, Name, SMAX_PS_Complaint_Required_Details_Check__c, SMAX_PS_Complaint_Required_Details__c FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.assertEquals(true, complaintWO.SMAX_PS_Complaint_Required_Details_Check__c);
		System.assertEquals(true, complaintWO.SMAX_PS_Complaint_Required_Details__c.contains('HSI'));
		System.assertEquals(true, complaintWO.SMAX_PS_Complaint_Required_Details__c.contains('Manual Complaint'));
		System.assertEquals(true, complaintWO.SMAX_PS_Complaint_Required_Details__c.contains('Fault Codes'));

		// Try to Complete.. catch the Error
		wo.SVMXC__Order_Status__c = 'Work Complete';
		Database.SaveResult sr = Database.update(wo, false);

		// SVMXCFG-327 - Use a Order Status / Message field instead of Apex Errors
		//System.debug('WO COMPLAINTS: Complete Error = ' + sr.getErrors());
		//System.assertEquals(false, sr.isSuccess());
		//System.assertEquals(true, (sr.getErrors() + '').contains('ACTIONS NEEDED'));
		SVMXC__Service_Order__c completeWO = [SELECT Id, Name, SMAX_PS_Completion_Errors__c, SVMXC__Order_Status__c FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.assertEquals('Work Complete - Error', completeWO.SVMXC__Order_Status__c);
		System.assertEquals(true, completeWO.SMAX_PS_Completion_Errors__c.contains('ACTIONS NEEDED'));

		// Fill in complaint data, Complete again.. should work now
		wo = new SVMXC__Service_Order__c();
		wo.Id = completeWO.Id;
		wo.SMAX_PS_Q1_Answer__c = 'A1';
		wo.SMAX_PS_Q2_Answer__c = 'A2';
		wo.SMAX_PS_Q3_Answer__c = 'A3';
		wo.SMAX_PS_Q4_Answer__c = 'A4';
		wo.SMAX_PS_Q5_Answer__c = 'A5';
		update wo;

		wo.SMAX_PS_HSI2_Answer__c = 'No';
		wo.SMAX_PS_Q1_Response__c = 'No';
		wo.SMAX_PS_Q2_Response__c = 'Yes';
		wo.SMAX_PS_Q3_Response__c = 'No';
		wo.SMAX_PS_Q4_Response__c = 'Yes';
		wo.SMAX_PS_Q5_Response__c = 'No';
		wo.SVMXC__Order_Status__c = 'Work Complete';
		update wo;

		completeWO = [SELECT Id, Name, SMAX_PS_Completion_Errors__c, SVMXC__Order_Status__c FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.debug('COMPLAINTS: Complete WO: ' + completeWO);
		System.assertEquals('Work Complete', completeWO.SVMXC__Order_Status__c);
		System.assertEquals(null, completeWO.SMAX_PS_Completion_Errors__c);

		Test.stopTest();
	}

	static testMethod void ipCustomerMasterTest()
	{   
		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001','GB');

		Account soldTo = SMAX_PS_TestDataFactory.createTestAccount('IP Partner Test', 'TESTX00FF001','GB');
		Map<String, Account> acctMap = SMAX_PS_TestDataFactory.createTestPartnerAccounts(soldTo);

		// SVMXCFG-794 Copy Payer E-Invoice Fields to WO
		Account payer = acctMap.get('Payer');
		payer.PKI_SAP_EInvoice_Platform_Id__c = 'PLATFORM-10010101';
		payer.PKI_SAP_EInvoice_Customer_Id__c = 'CUSTOMER-10010101';
		update payer;

		Contact cont = SMAX_PS_TestDataFactory.createTestContact('Sir', 'Testalot', acct, 'TESTX00000001A');
		Product2 pd = SMAX_PS_TestDataFactory.createTestProduct('TestProduct', '106018','TST');
		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct,'TestLocationSite', '121212','LOC123');

		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('123456',acct,loc,'5545333',pd);
		//ip.SMAX_PS_SoldTo_Account__c = soldTo.Id;
		//ip.SMAX_PS_ShipTo_Account__c = acctMap.get('ShipTo').Id;
		//ip.SMAX_PS_BillTo_Account__c = acctMap.get('BillTo').Id;
		//ip.SMAX_PS_Payer_Account__c = acctMap.get('Payer').Id;
		ip.SMAX_PS_SoldTo_ExtId__c = soldTo.PKI_SAP_Customer_Number__c;
		ip.SMAX_PS_ShipTo_ExtId__c = acctMap.get('ShipTo').PKI_SAP_Customer_Number__c;
		ip.SMAX_PS_BillTo_ExtId__c = acctMap.get('BillTo').PKI_SAP_Customer_Number__c;
		ip.SMAX_PS_Payer_ExtId__c = acctMap.get('Payer').PKI_SAP_Customer_Number__c;
		// SVMXCFG-903 Copy Local Language Accounts to WO
		ip.SMAX_PS_LL_BillTo_ExtId__c = acctMap.get('LocalLangBillTo').PKI_SAP_Customer_Number__c;
		ip.SMAX_PS_LL_ShipTo_ExtId__c = acctMap.get('LocalLangShipTo').PKI_SAP_Customer_Number__c;
		update ip;

		// Insert Work Order
		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createWO(ip, cont);

		SVMXC__Service_Order__c result = [SELECT Id, Name, SVMXC__Company__c, SMAX_PS_ShipTo__c, SMAX_PS_BillTo__c, SMAX_PS_Payer__c,
			SMAX_PS_EInvoice_Platform_Id__c, SMAX_PS_EInvoice_Customer_Id__c,
			SMAX_PS_Local_Language_Bill_To_Account__c, SMAX_PS_Local_Language_Ship_To_Account__c
			FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		
		ip = [SELECT Id, Name, SMAX_PS_SoldTo_Account__c, SMAX_PS_ShipTo_Account__c, SMAX_PS_BillTo_Account__c,
				SMAX_PS_Payer_Account__c, SMAX_PS_LL_BillTo_Account__c, SMAX_PS_LL_ShipTo_Account__c
			FROM SVMXC__Installed_Product__c WHERE Id = :ip.Id];
		System.assertNotEquals(null, ip.SMAX_PS_SoldTo_Account__c);

		System.assertEquals(ip.SMAX_PS_SoldTo_Account__c, result.SVMXC__Company__c);
		System.assertEquals(ip.SMAX_PS_ShipTo_Account__c, result.SMAX_PS_ShipTo__c);
		System.assertEquals(ip.SMAX_PS_BillTo_Account__c, result.SMAX_PS_BillTo__c);
		System.assertEquals(ip.SMAX_PS_Payer_Account__c, result.SMAX_PS_Payer__c);

		System.assertEquals(payer.PKI_SAP_EInvoice_Platform_Id__c, result.SMAX_PS_EInvoice_Platform_Id__c);
		System.assertEquals(payer.PKI_SAP_EInvoice_Customer_Id__c, result.SMAX_PS_EInvoice_Customer_Id__c);

		System.assertEquals(ip.SMAX_PS_LL_BillTo_Account__c, result.SMAX_PS_Local_Language_Bill_To_Account__c);
		System.assertEquals(ip.SMAX_PS_LL_ShipTo_Account__c, result.SMAX_PS_Local_Language_Ship_To_Account__c);
	}

	// SVMXCFG-647 - Added seeAllData=true to prevent managed package error on createTestUser(...)
	//@isTest(seeAllData=true)
	@isTest(seeAllData=false)
	static void woLoadTest()
	{
		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001','GB');

		Account soldTo = SMAX_PS_TestDataFactory.createTestAccount('IP Partner Test', 'TESTX00FF001','GB');
		Map<String, Account> acctMap = SMAX_PS_TestDataFactory.createTestPartnerAccounts(soldTo);

		Account sapAcct = SMAX_PS_TestDataFactory.createTestAccount('SAP Partner Test', 'TESTX00SAP001','GB');
		Map<String, Account> sapAcctMap = SMAX_PS_TestDataFactory.createTestPartnerAccounts(sapAcct);

		Contact cont = SMAX_PS_TestDataFactory.createTestContact('Sir', 'Testalot', acct, 'TESTX00000001A');
		Product2 pd = SMAX_PS_TestDataFactory.createTestProduct('TestProduct', '106018','TST');
		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct,'TestLocationSite', '121212','LOC123');

		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('123456',acct,loc,'5545333',pd);
		ip.SMAX_PS_SoldTo_Account__c = soldTo.Id;
		ip.SMAX_PS_ShipTo_Account__c = acctMap.get('ShipTo').Id;
		ip.SMAX_PS_BillTo_Account__c = acctMap.get('BillTo').Id;
		ip.SMAX_PS_Payer_Account__c = acctMap.get('Payer').Id;
		update ip;

		Profile p = [SELECT Id FROM Profile WHERE Name = 'Application Integration profiles'];
		User integrationUser = new User(alias = 'itest', email = 'testIntegration@yahoo.com',
			emailEncodingKey = 'UTF-8', languageLocaleKey = 'en_US', firstname = 'Testopher', lastName = 'Testintegration',
			localeSidKey = 'en_US', timeZoneSidKey = 'America/New_York', profileId = p.Id,
			username = 'testIntegration@yahoo.com', communityNickname = 'TestieInt');
		insert integrationUser;

		System.runAs(integrationUser)
		{
			// Insert Work Order
			RecordType fsRecType = SMAX_PS_Utility.getRecordType('SVMXC__Service_Order__c', 'Field_Service');
			Date startDate = System.today();
			SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
			wo.RecordTypeId = fsRecType.Id;
			wo.SVMXC__Component__c = ip.id;
			wo.SVMXC__Perform_Auto_Entitlement__c = TRUE;
			wo.SMAX_PS_SAP_OrderType__c = 'ZM02';
			wo.SMAX_PS_SAP_ActivityType__c = 'REP';
			wo.SVMXC__Site__c = ip.SVMXC__Site__c;
			wo.SVMXC__Scheduled_Date__c = startDate.addMonths(1);
			wo.SVMXC__Contact__c = cont.Id;
			wo.SVMXC__Company__c = sapAcct.Id;
			wo.SMAX_PS_ShipTo__c = sapAcctMap.get('ShipTo').Id;
			wo.SMAX_PS_BillTo__c = sapAcctMap.get('BillTo').Id;
			wo.SMAX_PS_Payer__c = sapAcctMap.get('Payer').Id;
			wo.SVMX_PS_External_ID__c = 'SAP000000000';
			wo.SMAX_PS_Perform_Auto_Assignment__c = true;
			wo.SMAX_PS_SAP_Work_Center__c = 'TSNULL'; // Not found.. tech will be null
			wo.SMAX_PS_SAP_Maintenance_Plant__c = 'TS12';
			insert wo;

			SVMXC__Service_Order__c result = [SELECT Id, Name, SVMXC__Billing_Type__c, SVMXC__Order_Type__c, 
				SVMXC__Company__c, SMAX_PS_ShipTo__c, SMAX_PS_BillTo__c, SMAX_PS_Payer__c 
				FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
			// Make sure correct SMax values assigned..
			System.assertEquals('Billable', result.SVMXC__Billing_Type__c);
			System.assertEquals('Repair', result.SVMXC__Order_Type__c);

			// Make sure the triggers do not change the values...
			System.assertEquals(wo.SVMXC__Company__c, result.SVMXC__Company__c);
			System.assertEquals(wo.SMAX_PS_ShipTo__c, result.SMAX_PS_ShipTo__c);
			System.assertEquals(wo.SMAX_PS_BillTo__c, result.SMAX_PS_BillTo__c);
			System.assertEquals(wo.SMAX_PS_Payer__c, result.SMAX_PS_Payer__c);

			// SVMXINT-605 End of WO Load, send UPDATE even if above logic didnt fire
			// Simulate the update at the end of the load.. make sure an event is sent
			wo.SMAX_PS_SAP_SystemStatus__c = 'REL';
			wo.SMAX_PS_CreditHold__c = false;
			update wo;
		}
	}

	static testMethod void testOneClickComplete_Simple()
	{
		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001','GB');
		Contact cont = SMAX_PS_TestDataFactory.createTestContact('Sir', 'Testalot', acct, 'TESTX00000001A');
		Product2 pd = SMAX_PS_TestDataFactory.createTestProduct('TestProduct', '106018','TST');
		pd.SMAX_PS_Super_Business_Unit__c = 'DAS';
		update pd;

		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct,'TestLocationSite', '121212','LOC123');
		loc.SMAX_PS_MaintenancePlant__c = 'TT12';
		update loc;

		SVMXC__Site__c expLoc = SMAX_PS_TestDataFactory.createTestLocation(acct,'Test Expense Loc', 'TT12F000', 'LOC123');

		Product2 laborProd = SMAX_PS_TestDataFactory.createTestProduct('TestLabor', 'LAB100101', 'LABR', 'Labor');
		Product2 travelProd = SMAX_PS_TestDataFactory.createTestProduct('TestTravel', 'TRV10011', 'TRVL', 'Travel');
		SMAX_PS_Fault_Code__c fc = SMAX_PS_TestDataFactory.createTestFaultCode('TFAM', 'TFAM-TTT', 'TTT2', 'Testing', FALSE);

		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('123456',acct,loc,'5545333',pd);

		// Insert Work Order
		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createWO(ip, cont);

		SVMXC__Service_Order__c result = [SELECT Id, Name, SMAX_PS_Super_Business_Unit__c FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.assertEquals(pd.SMAX_PS_Super_Business_Unit__c, result.SMAX_PS_Super_Business_Unit__c);

		// Simulate SAP success
		wo.SVMX_PS_External_ID__c = 'SO001991992';
		wo.SMAX_PS_SAP_SystemStatus__c = 'REL';
		wo.SMAX_PS_CreditHold__c = false;
		update wo;

		Test.startTest();

		Id usage = Schema.SObjectType.SVMXC__Service_Order_Line__c.getRecordTypeInfosByName().get('Usage/Consumption').getRecordTypeId();
		SVMXC__Service_Order_Line__c laborLine = new SVMXC__Service_Order_Line__c(
			SVMXC__Service_Order__c=wo.Id, RecordTypeId=usage, SVMXC__Line_Type__c = 'Labor', SVMXC__Line_Status__c='Priced',
			SVMXC__Product__c = laborProd.Id, SVMXC__Actual_Quantity2__c = 1.5);
		SVMXC__Service_Order_Line__c travelLine = new SVMXC__Service_Order_Line__c(
			SVMXC__Service_Order__c=wo.Id, RecordTypeId=usage, SVMXC__Line_Type__c = 'Travel', SVMXC__Line_Status__c='Priced',
			SVMXC__Product__c = travelProd.Id, SVMXC__Actual_Quantity2__c = 2);
		SVMXC__Service_Order_Line__c fcl = new SVMXC__Service_Order_Line__c(
			SVMXC__Service_Order__c=wo.Id, RecordTypeId=usage, SVMXC__Line_Type__c = 'Fault Code', SVMXC__Line_Status__c='Open',
			SMAX_PS_Fault_Code__c = fc.Id);
		List<SVMXC__Service_Order_Line__c> lines = new List<SVMXC__Service_Order_Line__c> { laborLine, travelLine, fcl };
		insert lines;

		wo.SVMXC__Order_Status__c='Work Complete';  // One-Click Complete
		update wo;

		// Should fail.. No Fault Lines..
		//result = [SELECT Id, Name, SVMXC__Order_Status__c FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		//System.assertEquals('Work Complete - Error', result.SVMXC__Order_Status__c);

		result = [SELECT Id, Name, SVMXC__Order_Status__c, SMAX_PS_Completion_Errors__c FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.assertEquals(null, result.SMAX_PS_Completion_Errors__c);
		System.assertEquals('Work Complete - Pending', result.SVMXC__Order_Status__c);

		List<SVMXC__Service_Order_Line__c> lineResults = [SELECT Id, Name, SVMXC__Line_Status__c FROM SVMXC__Service_Order_Line__c WHERE SVMXC__Service_Order__c = :wo.Id];
		for (SVMXC__Service_Order_Line__c lineResult : lineResults)
		{
			System.assertEquals('Submitted', lineResult.SVMXC__Line_Status__c);
		}

		// Simulate a success response from SAP
		SMAX_PS_WorkOrderDebriefService.DebriefResponse rsp = new SMAX_PS_WorkOrderDebriefService.DebriefResponse();
		rsp.ServiceOrderNumber = wo.SVMX_PS_External_ID__c;
		rsp.NotificationNumber = 'NO' + wo.SVMX_PS_External_ID__c;
		rsp.CreditHold = false;
		rsp.SystemStatus = 'TECO';
		rsp.UserStatus = 'CMPT;DIR;SRA';
		rsp.TransactionNumber = 'IDOC0007';
		rsp.Lines = new List<SMAX_PS_WorkOrderDebriefService.DebriefLine>();
		for (SVMXC__Service_Order_Line__c lineResult : lineResults)
		{
			SMAX_PS_WorkOrderDebriefService.DebriefLine dline = new SMAX_PS_WorkOrderDebriefService.DebriefLine();
			dline.LineId = lineResult.Name;
			dline.ConfirmationNumber = 'SAPCONF-' + lineResult.Name;
			rsp.Lines.add(dline);
		}
		String svcResult = SMAX_PS_WorkOrderDebriefService.submitDebriefResponse(rsp);
		System.assertEquals('Successfully processed Debrief Response', svcResult);

		result = [SELECT Id, Name, SVMXC__Order_Status__c, SMAX_PS_Completion_Errors__c FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.assertEquals(null, result.SMAX_PS_Completion_Errors__c);
		System.assertEquals('Work Complete', result.SVMXC__Order_Status__c);

		Test.stopTest();
	}

	static testMethod void testOneClickComplete_SkipPricing()
	{
		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001','GB');
		Contact cont = SMAX_PS_TestDataFactory.createTestContact('Sir', 'Testalot', acct, 'TESTX00000001A');
		Product2 pd = SMAX_PS_TestDataFactory.createTestProduct('TestProduct', '106018','TST');
		pd.SMAX_PS_Super_Business_Unit__c = 'DAS';
		update pd;

		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct,'TestLocationSite', '121212','LOC123');
		loc.SMAX_PS_MaintenancePlant__c = 'TT12';
		update loc;

		SVMXC__Site__c expLoc = SMAX_PS_TestDataFactory.createTestLocation(acct,'Test Expense Loc', 'TT12F000', 'LOC123');

		Product2 laborProd = SMAX_PS_TestDataFactory.createTestProduct('TestLabor', 'LAB100101', 'LABR', 'Labor');
		Product2 travelProd = SMAX_PS_TestDataFactory.createTestProduct('TestTravel', 'TRV10011', 'TRVL', 'Travel');
		SMAX_PS_Fault_Code__c fc = SMAX_PS_TestDataFactory.createTestFaultCode('TFAM', 'TFAM-TTT', 'TTT2', 'Testing', FALSE);

		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('123456',acct,loc,'5545333',pd);

		Date startDate = System.today();
		Date endDate = startDate.addMonths(12);
		SVMXC__Service_Contract__c sc = SMAX_PS_TestDataFactory.createSvcMaintContract('TestServiceContract', ip.SVMXC__Company__c, startDate, endDate);
		SVMXC__Service_Contract__c item = SMAX_PS_TestDataFactory.createContractItem(sc, 'TestServiceContract', startDate, endDate);
		SVMXC__Service_Contract_Products__c cp = SMAX_PS_TestDataFactory.createCoveredIP(item, startDate, endDate, ip);
		SVMXC__Service_Contract_Services__c ent = SMAX_PS_TestDataFactory.createEntitlement(item,'REP', 0, 0);
		ent.SMAX_PS_ServicePartsDiscountCovered__c = 100;
		update ent;

		// Insert Work Order
		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createContractWO(ip, cont);

		SVMXC__Service_Order__c result = [SELECT Id, Name, SMAX_PS_Super_Business_Unit__c FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.assertEquals(pd.SMAX_PS_Super_Business_Unit__c, result.SMAX_PS_Super_Business_Unit__c);

		// Simulate SAP success
		wo.SVMX_PS_External_ID__c = 'SO001991992';
		wo.SMAX_PS_SAP_SystemStatus__c = 'REL';
		wo.SMAX_PS_CreditHold__c = false;
		update wo;

		Test.startTest();

		Id usage = Schema.SObjectType.SVMXC__Service_Order_Line__c.getRecordTypeInfosByName().get('Usage/Consumption').getRecordTypeId();
		SVMXC__Service_Order_Line__c laborLine = new SVMXC__Service_Order_Line__c(
			SVMXC__Service_Order__c=wo.Id, RecordTypeId=usage, SVMXC__Line_Type__c = 'Labor', SVMXC__Line_Status__c='Open',
			SVMXC__Product__c = laborProd.Id, SVMXC__Actual_Quantity2__c = 1.5);
		SVMXC__Service_Order_Line__c travelLine = new SVMXC__Service_Order_Line__c(
			SVMXC__Service_Order__c=wo.Id, RecordTypeId=usage, SVMXC__Line_Type__c = 'Travel', SVMXC__Line_Status__c='Open',
			SVMXC__Product__c = travelProd.Id, SVMXC__Actual_Quantity2__c = 2);
		SVMXC__Service_Order_Line__c fcl = new SVMXC__Service_Order_Line__c(
			SVMXC__Service_Order__c=wo.Id, RecordTypeId=usage, SVMXC__Line_Type__c = 'Fault Code', SVMXC__Line_Status__c='Open',
			SMAX_PS_Fault_Code__c = fc.Id);
		List<SVMXC__Service_Order_Line__c> lines = new List<SVMXC__Service_Order_Line__c> { laborLine, travelLine, fcl };
		insert lines;

		wo.SVMXC__Order_Status__c='Work Complete';  // One-Click Complete
		update wo;

		// Should fail.. No Fault Lines..
		//result = [SELECT Id, Name, SVMXC__Order_Status__c FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		//System.assertEquals('Work Complete - Error', result.SVMXC__Order_Status__c);

		result = [SELECT Id, Name, SVMXC__Order_Status__c, SMAX_PS_Completion_Errors__c FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.assertEquals(null, result.SMAX_PS_Completion_Errors__c);
		System.assertEquals('Work Complete - Pending', result.SVMXC__Order_Status__c);

		List<SVMXC__Service_Order_Line__c> lineResults = [SELECT Id, Name, SVMXC__Line_Status__c FROM SVMXC__Service_Order_Line__c WHERE SVMXC__Service_Order__c = :wo.Id];
		for (SVMXC__Service_Order_Line__c lineResult : lineResults)
		{
			System.assertEquals('Submitted', lineResult.SVMXC__Line_Status__c);
		}

		// Simulate a success response from SAP
		SMAX_PS_WorkOrderDebriefService.DebriefResponse rsp = new SMAX_PS_WorkOrderDebriefService.DebriefResponse();
		rsp.ServiceOrderNumber = wo.SVMX_PS_External_ID__c;
		rsp.NotificationNumber = 'NO' + wo.SVMX_PS_External_ID__c;
		rsp.CreditHold = false;
		rsp.CreditHoldReason = '';
		rsp.SystemStatus = 'TECO';
		rsp.UserStatus = 'CMPT';
		rsp.TransactionNumber = 'IDOC0007';
		rsp.Lines = new List<SMAX_PS_WorkOrderDebriefService.DebriefLine>();
		for (SVMXC__Service_Order_Line__c lineResult : lineResults)
		{
			SMAX_PS_WorkOrderDebriefService.DebriefLine dline = new SMAX_PS_WorkOrderDebriefService.DebriefLine();
			dline.LineId = lineResult.Name;
			dline.ConfirmationNumber = 'SAPCONF-' + lineResult.Name;
			rsp.Lines.add(dline);
		}
		String svcResult = SMAX_PS_WorkOrderDebriefService.submitDebriefResponse(rsp);
		System.assertEquals('Successfully processed Debrief Response', svcResult);

		result = [SELECT Id, Name, SVMXC__Order_Status__c, SMAX_PS_Completion_Errors__c FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.assertEquals(null, result.SMAX_PS_Completion_Errors__c);
		System.assertEquals('Work Complete', result.SVMXC__Order_Status__c);

		Test.stopTest();
	}

	static testMethod void testOneClickComplete_CantSubmit()
	{
		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001','GB');
		Contact cont = SMAX_PS_TestDataFactory.createTestContact('Sir', 'Testalot', acct, 'TESTX00000001A');
		Product2 pd = SMAX_PS_TestDataFactory.createTestProduct('TestProduct', '106018','TST');
		pd.SMAX_PS_Super_Business_Unit__c = 'DAS';
		update pd;

		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct,'TestLocationSite', '121212','LOC123');
		loc.SMAX_PS_MaintenancePlant__c = 'TT12';
		update loc;

		SVMXC__Site__c expLoc = SMAX_PS_TestDataFactory.createTestLocation(acct,'Test Expense Loc', 'TT12F000', 'LOC123');

		Product2 laborProd = SMAX_PS_TestDataFactory.createTestProduct('TestLabor', 'LAB100101', 'LABR', 'Labor');
		Product2 travelProd = SMAX_PS_TestDataFactory.createTestProduct('TestTravel', 'TRV10011', 'TRVL', 'Travel');
		SMAX_PS_Fault_Code__c fc = SMAX_PS_TestDataFactory.createTestFaultCode('TFAM', 'TFAM-TTT', 'TTT2', 'Testing', FALSE);

		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('123456',acct,loc,'5545333',pd);

		Date startDate = System.today();
		Date endDate = startDate.addMonths(12);
		SVMXC__Service_Contract__c sc = SMAX_PS_TestDataFactory.createSvcMaintContract('TestServiceContract', ip.SVMXC__Company__c, startDate, endDate);
		SVMXC__Service_Contract__c item = SMAX_PS_TestDataFactory.createContractItem(sc, 'TestServiceContract', startDate, endDate);
		SVMXC__Service_Contract_Products__c cp = SMAX_PS_TestDataFactory.createCoveredIP(item, startDate, endDate, ip);
		SVMXC__Service_Contract_Services__c ent = SMAX_PS_TestDataFactory.createEntitlement(item,'REP', 0, 0);
        ent.SVMXC__Labor_Discount_Covered__c = 10; // This discount wont allow it to submit without pricing
        ent.SVMXC__Travel_Discount_Covered__c = 100;
		update ent; 

		// Insert Work Order
		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createContractWO(ip, cont);

		SVMXC__Service_Order__c result = [SELECT Id, Name, SMAX_PS_Super_Business_Unit__c FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.assertEquals(pd.SMAX_PS_Super_Business_Unit__c, result.SMAX_PS_Super_Business_Unit__c);

		// Simulate SAP success
		wo.SVMX_PS_External_ID__c = 'SO001991992';
		wo.SMAX_PS_SAP_SystemStatus__c = 'REL';
		wo.SMAX_PS_CreditHold__c = false;
		update wo;

		Test.startTest();

		Id usage = Schema.SObjectType.SVMXC__Service_Order_Line__c.getRecordTypeInfosByName().get('Usage/Consumption').getRecordTypeId();
		SVMXC__Service_Order_Line__c laborLine = new SVMXC__Service_Order_Line__c(
			SVMXC__Service_Order__c=wo.Id, RecordTypeId=usage, SVMXC__Line_Type__c = 'Labor', SVMXC__Line_Status__c='Open',
			SVMXC__Product__c = laborProd.Id, SVMXC__Actual_Quantity2__c = 1.5);
		SVMXC__Service_Order_Line__c travelLine = new SVMXC__Service_Order_Line__c(
			SVMXC__Service_Order__c=wo.Id, RecordTypeId=usage, SVMXC__Line_Type__c = 'Travel', SVMXC__Line_Status__c='Open',
			SVMXC__Product__c = travelProd.Id, SVMXC__Actual_Quantity2__c = 2);
		SVMXC__Service_Order_Line__c fcl = new SVMXC__Service_Order_Line__c(
			SVMXC__Service_Order__c=wo.Id, RecordTypeId=usage, SVMXC__Line_Type__c = 'Fault Code', SVMXC__Line_Status__c='Invalid',
			SMAX_PS_Fault_Code__c = fc.Id); // Not Open, Priced, Canceled, Confirmed or Submitted.. Anything else will fail
		List<SVMXC__Service_Order_Line__c> lines = new List<SVMXC__Service_Order_Line__c> { laborLine, travelLine, fcl };
		insert lines;

		wo.SVMXC__Order_Status__c='Work Complete';  // One-Click Complete
		update wo;

		// Should fail.. No Fault Lines..
		//result = [SELECT Id, Name, SVMXC__Order_Status__c FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		//System.assertEquals('Work Complete - Error', result.SVMXC__Order_Status__c);

		result = [SELECT Id, Name, SVMXC__Order_Status__c, SMAX_PS_Completion_Errors__c FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.assertEquals(true, result.SMAX_PS_Completion_Errors__c.contains('Non-Confirmed line is not able to be Submitted'));
		System.assertEquals('Work Complete - Error', result.SVMXC__Order_Status__c);

		List<SVMXC__Service_Order_Line__c> lineResults = [SELECT Id, Name, SVMXC__Line_Status__c, SVMXC__Line_Type__c FROM SVMXC__Service_Order_Line__c WHERE SVMXC__Service_Order__c = :wo.Id];
		for (SVMXC__Service_Order_Line__c lineResult : lineResults)
		{
			if (lineResult.SVMXC__Line_Type__c == 'Labor')
				System.assertEquals('Open', lineResult.SVMXC__Line_Status__c);
			else if (lineResult.SVMXC__Line_Type__c == 'Travel')
				System.assertEquals('Submitted', lineResult.SVMXC__Line_Status__c);
		}

		// Should fail.. not allowed.
		SMAX_PS_WorkOrderDebriefService.DebriefResponse rsp = new SMAX_PS_WorkOrderDebriefService.DebriefResponse();
		rsp.ServiceOrderNumber = wo.SVMX_PS_External_ID__c;
		String svcResult = SMAX_PS_WorkOrderDebriefService.submitDebriefResponse(rsp);
		//System.assertEquals(true, svcResult.startsWith('Cannot process Debrief Response'));

		Test.stopTest();
	}

	static testMethod void testOneClickComplete_StuckLines()
	{
		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001','GB');
		Contact cont = SMAX_PS_TestDataFactory.createTestContact('Sir', 'Testalot', acct, 'TESTX00000001A');
		Product2 pd = SMAX_PS_TestDataFactory.createTestProduct('TestProduct', '106018','TST');
		pd.SMAX_PS_Super_Business_Unit__c = 'DAS';
		update pd;

		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct,'TestLocationSite', '121212','LOC123');
		loc.SMAX_PS_MaintenancePlant__c = 'TT12';
		update loc;

		SVMXC__Site__c expLoc = SMAX_PS_TestDataFactory.createTestLocation(acct,'Test Expense Loc', 'TT12F000', 'LOC123');

		Product2 laborProd = SMAX_PS_TestDataFactory.createTestProduct('TestLabor', 'LAB100101', 'LABR', 'Labor');
		Product2 travelProd = SMAX_PS_TestDataFactory.createTestProduct('TestTravel', 'TRV10011', 'TRVL', 'Travel');
		SMAX_PS_Fault_Code__c fc = SMAX_PS_TestDataFactory.createTestFaultCode('TFAM', 'TFAM-TTT', 'TTT2', 'Testing', FALSE);

		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('123456',acct,loc,'5545333',pd);

		// Insert Work Order
		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createWO(ip, cont);

		SVMXC__Service_Order__c result = [SELECT Id, Name, SMAX_PS_Super_Business_Unit__c FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.assertEquals(pd.SMAX_PS_Super_Business_Unit__c, result.SMAX_PS_Super_Business_Unit__c);

		// Simulate SAP success
		wo.SVMX_PS_External_ID__c = 'SO001991992';
		wo.SMAX_PS_SAP_SystemStatus__c = 'REL';
		wo.SMAX_PS_CreditHold__c = false;
		update wo;

		Test.startTest();

		Id usage = Schema.SObjectType.SVMXC__Service_Order_Line__c.getRecordTypeInfosByName().get('Usage/Consumption').getRecordTypeId();
		SVMXC__Service_Order_Line__c laborLine = new SVMXC__Service_Order_Line__c(
			SVMXC__Service_Order__c=wo.Id, RecordTypeId=usage, SVMXC__Line_Type__c = 'Labor', SVMXC__Line_Status__c='Submitted',
			SVMXC__Product__c = laborProd.Id, SVMXC__Actual_Quantity2__c = 1.5);
		SVMXC__Service_Order_Line__c travelLine = new SVMXC__Service_Order_Line__c(
			SVMXC__Service_Order__c=wo.Id, RecordTypeId=usage, SVMXC__Line_Type__c = 'Travel', SVMXC__Line_Status__c='Submitted',
			SVMXC__Product__c = travelProd.Id, SVMXC__Actual_Quantity2__c = 2);
		SVMXC__Service_Order_Line__c fcl = new SVMXC__Service_Order_Line__c(
			SVMXC__Service_Order__c=wo.Id, RecordTypeId=usage, SVMXC__Line_Type__c = 'Fault Code', SVMXC__Line_Status__c='Submitted',
			SMAX_PS_Fault_Code__c = fc.Id); // "Stuck" in Submitted.. this will fail
		List<SVMXC__Service_Order_Line__c> lines = new List<SVMXC__Service_Order_Line__c> { laborLine, travelLine, fcl };
		insert lines;

		wo.SVMXC__Order_Status__c='Work Complete';  // One-Click Complete
		update wo;

		// Should fail.. No Fault Lines..
		//result = [SELECT Id, Name, SVMXC__Order_Status__c FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		//System.assertEquals('Work Complete - Error', result.SVMXC__Order_Status__c);

		result = [SELECT Id, Name, SVMXC__Order_Status__c, SMAX_PS_Completion_Errors__c FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.assertEquals(true, result.SMAX_PS_Completion_Errors__c.contains('Wait for the 3 Submitted Line(s) to finish processing.'));
		System.assertEquals('Work Complete - Error', result.SVMXC__Order_Status__c);

		// Should fail.. not found.
		SMAX_PS_WorkOrderDebriefService.DebriefResponse rsp = new SMAX_PS_WorkOrderDebriefService.DebriefResponse();
		rsp.ServiceOrderNumber = 'FrankWasHere';
		String svcResult = SMAX_PS_WorkOrderDebriefService.submitDebriefResponse(rsp);
		System.assertEquals(true, svcResult.contains('Could NOT find Work Order with External ID'));

		Test.stopTest();
	}

	static testMethod void testOneClickComplete_NonConsumable()
	{
		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001','GB');
		Contact cont = SMAX_PS_TestDataFactory.createTestContact('Sir', 'Testalot', acct, 'TESTX00000001A');
		Product2 pd = SMAX_PS_TestDataFactory.createTestProduct('TestProduct', '106018','TST');
		pd.SMAX_PS_Super_Business_Unit__c = 'DAS';
		update pd;

		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct,'TestLocationSite', '121212','LOC123');
		loc.SMAX_PS_MaintenancePlant__c = 'BR12'; // This creates a "Non Consumable" Location
		update loc;

//		SVMXC__Site__c expLoc = SMAX_PS_TestDataFactory.createTestLocation(acct,'Test Expense Loc', 'TT12F000', 'LOC123');

		Product2 laborProd = SMAX_PS_TestDataFactory.createTestProduct('TestLabor', 'LAB100101', 'LABR', 'Labor');
		Product2 travelProd = SMAX_PS_TestDataFactory.createTestProduct('TestTravel', 'TRV10011', 'TRVL', 'Travel');
		Product2 partsProd = SMAX_PS_TestDataFactory.createTestProduct('TestPart', 'PRT100101', 'DAS', 'Service Parts');
		SMAX_PS_Fault_Code__c fc = SMAX_PS_TestDataFactory.createTestFaultCode('TFAM', 'TFAM-TTT', 'TTT2', 'Testing', FALSE);

		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('123456',acct,loc,'5545333',pd);

//		Date startDate = System.today();
//		Date endDate = startDate.addMonths(12);
//		SVMXC__Service_Contract__c sc = SMAX_PS_TestDataFactory.createSvcMaintContract('TestServiceContract', ip.SVMXC__Company__c, startDate, endDate);
//		SVMXC__Service_Contract__c item = SMAX_PS_TestDataFactory.createContractItem(sc, 'TestServiceContract', startDate, endDate);
//		SVMXC__Service_Contract_Products__c cp = SMAX_PS_TestDataFactory.createCoveredIP(item, startDate, endDate, ip);
//		SVMXC__Service_Contract_Services__c ent = SMAX_PS_TestDataFactory.createEntitlement(item,'REP', 0, 0);
//		ent.SVMXC__Labor_Discount_Covered__c = 10; // This discount wont allow it to submit without pricing
//		ent.SVMXC__Travel_Discount_Covered__c = 100;
//		update ent;

		// Insert Work Order
		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createWO(ip, cont);

		SVMXC__Service_Order__c result = [SELECT Id, Name, SMAX_PS_Super_Business_Unit__c FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.assertEquals(pd.SMAX_PS_Super_Business_Unit__c, result.SMAX_PS_Super_Business_Unit__c);

		// Simulate SAP success
		wo.SVMX_PS_External_ID__c = 'SO001991992';
		wo.SMAX_PS_SAP_SystemStatus__c = 'REL';
		wo.SMAX_PS_CreditHold__c = false;
		update wo;

		Test.startTest();

		Id usage = Schema.SObjectType.SVMXC__Service_Order_Line__c.getRecordTypeInfosByName().get('Usage/Consumption').getRecordTypeId();
		SVMXC__Service_Order_Line__c laborLine = new SVMXC__Service_Order_Line__c(
				SVMXC__Service_Order__c=wo.Id, RecordTypeId=usage, SVMXC__Line_Type__c = 'Labor', SVMXC__Line_Status__c='Priced',
				SVMXC__Product__c = laborProd.Id, SVMXC__Actual_Quantity2__c = 1.5);
		SVMXC__Service_Order_Line__c travelLine = new SVMXC__Service_Order_Line__c(
				SVMXC__Service_Order__c=wo.Id, RecordTypeId=usage, SVMXC__Line_Type__c = 'Travel', SVMXC__Line_Status__c='Priced',
				SVMXC__Product__c = travelProd.Id, SVMXC__Actual_Quantity2__c = 2);
		SVMXC__Service_Order_Line__c partsLine = new SVMXC__Service_Order_Line__c(
				SVMXC__Service_Order__c=wo.Id, RecordTypeId=usage, SVMXC__Line_Type__c = 'Parts', SVMXC__Line_Status__c='Priced',
				SVMXC__Product__c = partsProd.Id, SVMXC__Actual_Quantity2__c = 1, SVMXC__Consumed_From_Location__c = loc.Id);
		SVMXC__Service_Order_Line__c fcl = new SVMXC__Service_Order_Line__c(
				SVMXC__Service_Order__c=wo.Id, RecordTypeId=usage, SVMXC__Line_Type__c = 'Fault Code', SVMXC__Line_Status__c='Open',
				SMAX_PS_Fault_Code__c = fc.Id);
		List<SVMXC__Service_Order_Line__c> lines = new List<SVMXC__Service_Order_Line__c> { laborLine, travelLine, partsLine, fcl };
		insert lines;

		wo.SVMXC__Order_Status__c='Work Complete';  // One-Click Complete
		update wo;

		result = [SELECT Id, Name, SVMXC__Order_Status__c, SMAX_PS_Completion_Errors__c FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.assertEquals(true, result.SMAX_PS_Completion_Errors__c.contains('Non-Consumable'));
		System.assertEquals('Work Complete - Material Follow Up', result.SVMXC__Order_Status__c);

		List<SVMXC__Service_Order_Line__c> lineResults = [SELECT Id, Name, SVMXC__Line_Status__c, SVMXC__Line_Type__c FROM SVMXC__Service_Order_Line__c WHERE SVMXC__Service_Order__c = :wo.Id];
		for (SVMXC__Service_Order_Line__c lineResult : lineResults)
		{
			if (lineResult.SVMXC__Line_Type__c == 'Parts')
				System.assertEquals('Priced', lineResult.SVMXC__Line_Status__c);
			else
				System.assertEquals('Submitted', lineResult.SVMXC__Line_Status__c);
		}

		Test.stopTest();
	}

	static testMethod void testCancelWorkOrder()
	{
		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001','GB');
		Contact cont = SMAX_PS_TestDataFactory.createTestContact('Sir', 'Testalot', acct, 'TESTX00000001A');
		Product2 pd = SMAX_PS_TestDataFactory.createTestProduct('TestProduct', '106018','TST');
		pd.SMAX_PS_Super_Business_Unit__c = 'DAS';
		update pd;

		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct,'TestLocationSite', '121212','LOC123');
		loc.SMAX_PS_MaintenancePlant__c = 'TT12';
		update loc;

		SVMXC__Site__c expLoc = SMAX_PS_TestDataFactory.createTestLocation(acct,'Test Expense Loc', 'TT12F000', 'LOC123');

		Product2 laborProd = SMAX_PS_TestDataFactory.createTestProduct('TestLabor', 'LAB100101', 'LABR', 'Labor');
		Product2 travelProd = SMAX_PS_TestDataFactory.createTestProduct('TestTravel', 'TRV10011', 'TRVL', 'Travel');

		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('123456',acct,loc,'5545333',pd);

		// Insert Work Order
		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createWO(ip, cont);

		// Fake an Assignment..
		User techUser = new User(Id = UserInfo.getUserId());
		SVMXC__Service_Group_Members__c tech = SMAX_PS_TestDataFactory.createTestTechnician('TestTeam01', techUser, 'Test Tech1', 'TS12', 'T001');
		wo.SVMXC__Group_Member__c = tech.Id;
		update wo;

		Event e = new Event();
		e.Subject = 'Test Event';
		e.WhatId = wo.Id;
		e.OwnerId = techUser.Id;
		e.StartDateTime = System.now();
		e.EndDateTime = e.StartDateTime.addHours(3);
		insert e;

		SVMXC__Service_Order__c result = [SELECT Id, Name, SMAX_PS_Super_Business_Unit__c FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.assertEquals(pd.SMAX_PS_Super_Business_Unit__c, result.SMAX_PS_Super_Business_Unit__c);

		wo.SVMX_PS_External_ID__c = 'SO001991993';
		wo.SMAX_PS_SAP_SystemStatus__c = 'REL';
		update wo;

		Id usage = Schema.SObjectType.SVMXC__Service_Order_Line__c.getRecordTypeInfosByName().get('Usage/Consumption').getRecordTypeId();
		SVMXC__Service_Order_Line__c laborLine = new SVMXC__Service_Order_Line__c(
			SVMXC__Service_Order__c=wo.Id, RecordTypeId=usage, SVMXC__Line_Type__c = 'Labor', SVMXC__Line_Status__c='Confirmed',
			SVMXC__Product__c = laborProd.Id, SVMXC__Actual_Quantity2__c = 1.5);
		SVMXC__Service_Order_Line__c travelLine = new SVMXC__Service_Order_Line__c(
			SVMXC__Service_Order__c=wo.Id, RecordTypeId=usage, SVMXC__Line_Type__c = 'Travel', SVMXC__Line_Status__c='Confirmed',
			SVMXC__Product__c = travelProd.Id, SVMXC__Actual_Quantity2__c = 2);
		List<SVMXC__Service_Order_Line__c> lines = new List<SVMXC__Service_Order_Line__c> { laborLine, travelLine };
		insert lines;

		Test.startTest();

		wo = new SVMXC__Service_Order__c();
		wo.Id = result.Id;
		wo.SVMXC__Order_Status__c='Canceled';
		wo.SVMXC__Canceled_Date_Time__c = Datetime.now();
		wo.SVMX_PS_Canceled_Reason__c = 'Duplicate Entry';

		// Should fail.. Lines are not Canceled..
		Database.SaveResult results = Database.update(wo, false);
		System.assertEquals(false, results.isSuccess());

		List<Event> eventList = [SELECT Id, Subject FROM Event WHERE WhatId = :wo.Id];
		System.assertEquals(1, eventList.size());

		// Cancel the lines..
		for (SVMXC__Service_Order_Line__c line : lines)
		{
			//line.SVMXC__Line_Status__c = 'Canceled';
			line.SMAX_PS_Cancel_Line__c = true;
			line.SMAX_PS_Cancel_Reason__c = 'Other';
		}
		update lines;

		// Try again..
		wo = new SVMXC__Service_Order__c();
		wo.Id = result.Id;
		wo.SVMXC__Order_Status__c='Canceled';
		wo.SVMXC__Canceled_Date_Time__c = Datetime.now();
		wo.SVMX_PS_Canceled_Reason__c = 'Duplicate Entry';

		update wo;

		Test.stopTest();

		// SVMXCFG-648 Make sure Tech is removed, and Event is deleted
		result = [SELECT Id, Name, SVMXC__Order_Status__c, SVMXC__Group_Member__c
			FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.assertEquals(null, result.SVMXC__Group_Member__c);

		// SVMXCFG-837 Make sure WO Status does NOT change to Open in this scenario..
		System.assertEquals('Canceled', result.SVMXC__Order_Status__c);

		eventList = [SELECT Id, Subject FROM Event WHERE WhatId = :wo.Id];
		System.assertEquals(0, eventList.size());
	}

	static testMethod void testUnassignWorkOrder()
	{
		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001','GB');
		Contact cont = SMAX_PS_TestDataFactory.createTestContact('Sir', 'Testalot', acct, 'TESTX00000001A');
		Product2 pd = SMAX_PS_TestDataFactory.createTestProduct('TestProduct', '106018','TST');
		pd.SMAX_PS_Super_Business_Unit__c = 'DAS';
		update pd;

		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct,'TestLocationSite', '121212','LOC123');
		loc.SMAX_PS_MaintenancePlant__c = 'TT12';
		update loc;

		SVMXC__Site__c expLoc = SMAX_PS_TestDataFactory.createTestLocation(acct,'Test Expense Loc', 'TT12F000', 'LOC123');

		Product2 laborProd = SMAX_PS_TestDataFactory.createTestProduct('TestLabor', 'LAB100101', 'LABR', 'Labor');
		Product2 travelProd = SMAX_PS_TestDataFactory.createTestProduct('TestTravel', 'TRV10011', 'TRVL', 'Travel');

		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('123456',acct,loc,'5545333',pd);

		// Insert Work Order
		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createWO(ip, cont);

		// Fake an Assignment..
		User techUser = new User(Id = UserInfo.getUserId());
		SVMXC__Service_Group_Members__c tech = SMAX_PS_TestDataFactory.createTestTechnician('TestTeam01', techUser, 'Test Tech1', 'TS12', 'T001');
		wo.SVMXC__Group_Member__c = tech.Id;
		wo.SMAX_PS_SAP_SystemStatus__c = 'REL';
		update wo;

		SVMXC__Service_Order__c result = [SELECT Id, Name, SVMXC__Order_Status__c, SVMXC__Group_Member__c
			FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.assertNotEquals(null, result.SVMXC__Group_Member__c);
		System.assertEquals('Assigned', result.SVMXC__Order_Status__c);

		// Unassign WO.. 
		result.SVMXC__Group_Member__c = null;
		update result;

		result = [SELECT Id, Name, SVMXC__Order_Status__c, SVMXC__Group_Member__c
			FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.assertEquals(null, result.SVMXC__Group_Member__c);
		System.assertEquals('Open', result.SVMXC__Order_Status__c);
	}

	static testMethod void testWorkOrderSync()
	{
		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001');
		Contact c = SMAX_PS_TestDataFactory.createTestContact('Testie', 'Testerson', acct, 'TEST000000101');
		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct, 'Test Location', 'TESTLOC001', 'TSTC01');
		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('TESTX0000234001', acct, loc, 'TST001');
		Product2 laborProd = SMAX_PS_TestDataFactory.createTestProduct('TestLabor', 'LAB10010', 'LABR', 'Labor');
		Product2 travelProd = SMAX_PS_TestDataFactory.createTestProduct('TestTravel', 'TRV10010', 'TRVL', 'Travel');
		Product2 partsProd = SMAX_PS_TestDataFactory.createTestProduct('TestParts', 'PRT10010', 'PRTS', 'Parts');

		Date startDate = System.today();
		Date endDate = startDate.addMonths(12);
	    SVMXC__Service_Contract__c sc = SMAX_PS_TestDataFactory.createSvcMaintContract('TestServiceContract', ip.SVMXC__Company__c, startDate, endDate);
	    SVMXC__Service_Contract__c item = SMAX_PS_TestDataFactory.createContractItem(sc, 'TestServiceContract', startDate, endDate);
	    SVMXC__Service_Contract_Products__c cp = SMAX_PS_TestDataFactory.createCoveredIP(item, startDate, endDate, ip);
        SVMXC__Service_Contract_Services__c ent = SMAX_PS_TestDataFactory.createEntitlement(item,'REP', 5, 2);

		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createContractWO(ip, c);
        SVMXC__Service_Order_Line__c wd1 = SMAX_PS_TestDataFactory.createWorkDetailUsage(wo, 'Labor', laborProd);
        SVMXC__Service_Order_Line__c wd2 = SMAX_PS_TestDataFactory.createWorkDetailUsage(wo, 'Travel', travelProd);
        SVMXC__Service_Order_Line__c wd3 = SMAX_PS_TestDataFactory.createWorkDetailUsage(wo, 'Parts', partsProd);
        List<SVMXC__Service_Order_Line__c> lines = new List<SVMXC__Service_Order_Line__c>();
        lines.add(wd1);
        lines.add(wd2);
        lines.add(wd3);

        SVMXC.INTF_WebServicesDef.INTF_Request request = new SVMXC.INTF_WebServicesDef.INTF_Request();
        request.valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();

		SVMXC.INTF_WebServicesDef.SVMXMap objSVXMMap = new SVMXC.INTF_WebServicesDef.SVMXMap();
		objSVXMMap.key = 'Work_Order_Id';
		objSVXMMap.value = wo.Id + '';
		request.valueMap.add(objSVXMMap);

		SVMXC.INTF_WebServicesDef.SVMXMap objSVXMMap1 = new SVMXC.INTF_WebServicesDef.SVMXMap();
		objSVXMMap1.key = 'Work_Order_Action';
		objSVXMMap1.value = 'REFRESH';
		request.valueMap.add(objSVXMMap1);

        SVMXC.INTF_WebServicesDef.INTF_Response result1 = SMAX_PS_WorkOrderService.syncWorkOrder(request);
 
		objSVXMMap1.value = 'SUBMIT';
        SVMXC.INTF_WebServicesDef.INTF_Response result2 = SMAX_PS_WorkOrderService.syncWorkOrder(request);

		objSVXMMap1.value = 'COMPLETE';
        SVMXC.INTF_WebServicesDef.INTF_Response result3 = SMAX_PS_WorkOrderService.syncWorkOrder(request);
	}

	static testMethod void testOneClickComplete_Error()
	{
		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001','GB');
		Contact cont = SMAX_PS_TestDataFactory.createTestContact('Sir', 'Testalot', acct, 'TESTX00000001A');
		Product2 pd = SMAX_PS_TestDataFactory.createTestProduct('TestProduct', '106018','TST');
		pd.SMAX_PS_Super_Business_Unit__c = 'DAS';
		update pd;

		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct,'TestLocationSite', '121212','LOC123');
		loc.SMAX_PS_MaintenancePlant__c = 'TT12';
		update loc;

		SVMXC__Site__c expLoc = SMAX_PS_TestDataFactory.createTestLocation(acct,'Test Expense Loc', 'TT12F000', 'LOC123');

		Product2 laborProd = SMAX_PS_TestDataFactory.createTestProduct('TestLabor', 'LAB100101', 'LABR', 'Labor');
		Product2 travelProd = SMAX_PS_TestDataFactory.createTestProduct('TestTravel', 'TRV10011', 'TRVL', 'Travel');
		SMAX_PS_Fault_Code__c fc = SMAX_PS_TestDataFactory.createTestFaultCode('TFAM', 'TFAM-TTT', 'TTT2', 'Testing', FALSE);

		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('123456',acct,loc,'5545333',pd);

		// Insert Work Order
		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createWO(ip, cont);

		SVMXC__Service_Order__c result = [SELECT Id, Name, SMAX_PS_Super_Business_Unit__c FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.assertEquals(pd.SMAX_PS_Super_Business_Unit__c, result.SMAX_PS_Super_Business_Unit__c);

		// Simulate SAP success
		wo.SVMX_PS_External_ID__c = 'SO001991992';
		wo.SMAX_PS_SAP_SystemStatus__c = 'REL';
		wo.SMAX_PS_CreditHold__c = false;
		update wo;

		Test.startTest();

		Id usage = Schema.SObjectType.SVMXC__Service_Order_Line__c.getRecordTypeInfosByName().get('Usage/Consumption').getRecordTypeId();
		SVMXC__Service_Order_Line__c laborLine = new SVMXC__Service_Order_Line__c(
			SVMXC__Service_Order__c=wo.Id, RecordTypeId=usage, SVMXC__Line_Type__c = 'Labor', SVMXC__Line_Status__c='Priced',
			SVMXC__Product__c = laborProd.Id, SVMXC__Actual_Quantity2__c = 1.5);
		SVMXC__Service_Order_Line__c travelLine = new SVMXC__Service_Order_Line__c(
			SVMXC__Service_Order__c=wo.Id, RecordTypeId=usage, SVMXC__Line_Type__c = 'Travel', SVMXC__Line_Status__c='Priced',
			SVMXC__Product__c = travelProd.Id, SVMXC__Actual_Quantity2__c = 2);
		SVMXC__Service_Order_Line__c fcl = new SVMXC__Service_Order_Line__c(
			SVMXC__Service_Order__c=wo.Id, RecordTypeId=usage, SVMXC__Line_Type__c = 'Fault Code', SVMXC__Line_Status__c='Open',
			SMAX_PS_Fault_Code__c = fc.Id);
		List<SVMXC__Service_Order_Line__c> lines = new List<SVMXC__Service_Order_Line__c> { laborLine, travelLine, fcl };
		insert lines;

		wo.SVMXC__Order_Status__c='Work Complete';  // One-Click Complete
		update wo;

		// Should fail.. No Fault Lines..
		//result = [SELECT Id, Name, SVMXC__Order_Status__c FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		//System.assertEquals('Work Complete - Error', result.SVMXC__Order_Status__c);

		result = [SELECT Id, Name, SVMXC__Order_Status__c, SMAX_PS_Completion_Errors__c FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.assertEquals(null, result.SMAX_PS_Completion_Errors__c);
		System.assertEquals('Work Complete - Pending', result.SVMXC__Order_Status__c);

		List<SVMXC__Service_Order_Line__c> lineResults = [SELECT Id, Name, SVMXC__Line_Status__c, SVMXC__Line_Type__c FROM SVMXC__Service_Order_Line__c WHERE SVMXC__Service_Order__c = :wo.Id];
		for (SVMXC__Service_Order_Line__c lineResult : lineResults)
		{
			System.assertEquals('Submitted', lineResult.SVMXC__Line_Status__c);
		}

		// Simulate a success response from SAP
		SMAX_PS_WorkOrderDebriefService.DebriefResponse rsp = new SMAX_PS_WorkOrderDebriefService.DebriefResponse();
		rsp.ServiceOrderNumber = wo.SVMX_PS_External_ID__c;
		rsp.NotificationNumber = 'NO' + wo.SVMX_PS_External_ID__c;
		rsp.CreditHold = false;
		rsp.SystemStatus = 'TECO';
		rsp.UserStatus = 'CMPT;DIR;SRA';
		rsp.TransactionNumber = 'IDOC0007';
		rsp.ErrorMessage = 'Test Header Msg';
		rsp.Lines = new List<SMAX_PS_WorkOrderDebriefService.DebriefLine>();
		for (SVMXC__Service_Order_Line__c lineResult : lineResults)
		{
			SMAX_PS_WorkOrderDebriefService.DebriefLine dline = new SMAX_PS_WorkOrderDebriefService.DebriefLine();
			dline.LineId = lineResult.Name;
			dline.LineType = lineResult.SVMXC__Line_Type__c;
			//dline.ConfirmationNumber = 'SAPCONF-' + lineResult.Name;
			if (dline.LineType == 'Fault Code')
			{
				dline.ConfirmationNumber = '0000000000';
			}
			else
			{
				dline.ConfirmationNumber = '0000000000-00000000';
				dline.ErrorMessage = 'Testing Line Errors';
			}
			rsp.Lines.add(dline);
		}
		SMAX_PS_WorkOrderDebriefService.DebriefLine dlineX = new SMAX_PS_WorkOrderDebriefService.DebriefLine();
		dlineX.LineId = 'BAD_LINE_ID';
		rsp.Lines.add(dlineX);

		String svcResult = SMAX_PS_WorkOrderDebriefService.submitDebriefResponse(rsp);
		//System.assertEquals('Successfully processed Debrief Response', svcResult);

		//result = [SELECT Id, Name, SVMXC__Order_Status__c, SMAX_PS_Completion_Errors__c FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		//System.assertEquals(null, result.SMAX_PS_Completion_Errors__c);
		//System.assertEquals('Work Complete', result.SVMXC__Order_Status__c);

		Test.stopTest();
	}

	static testMethod void testInstalledProductSystemId()
	{
		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001','GB');
		Contact cont = SMAX_PS_TestDataFactory.createTestContact('Sir', 'Testalot', acct, 'TESTX00000001A');
		Product2 pd = SMAX_PS_TestDataFactory.createTestProduct('TestProduct', '106018','TST');

		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct,'TestLocationSite', '121212','LOC123');


		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('123456',acct,loc,'5545333',pd);
		ip.SMAX_PS_System_ID__c='000-01';
		update ip;

		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createWO(ip, cont);
		system.debug('WO ID = ' + wo.id);

		SVMXC__Service_Order__c result = [SELECT Id,SMAX_PS_System_ID__c
											FROM SVMXC__Service_Order__c
											WHERE id = :wo.id
											LIMIT 1];

		system.debug('Result ID = ' + result.id);
		system.debug('IP System ID = ' + ip.SMAX_PS_System_ID__c);
		system.debug('WO System ID = ' + result.SMAX_PS_System_ID__c);									
		system.assertEquals(ip.SMAX_PS_System_ID__c,result.SMAX_PS_System_ID__c);
	}

	static testMethod void testPendingIP()
	{
		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001','GB');
		Contact cont = SMAX_PS_TestDataFactory.createTestContact('Sir', 'Testalot', acct, 'TESTX00000001A');
		Product2 pd = SMAX_PS_TestDataFactory.createTestProduct('TestProduct', '106018','TST');
		//pd.SMAX_PS_Super_Business_Unit__c = 'DAS';
		//update pd;

		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct,'TestLocationSite', '121212','LOC123');
		//loc.SMAX_PS_MaintenancePlant__c = 'TT12';
		//update loc;

		SVMXC__Site__c expLoc = SMAX_PS_TestDataFactory.createTestLocation(acct,'Test Expense Loc', 'TT12F000', 'LOC123');

		Product2 laborProd = SMAX_PS_TestDataFactory.createTestProduct('TestLabor', 'LAB100101', 'LABR', 'Labor');
		Product2 travelProd = SMAX_PS_TestDataFactory.createTestProduct('TestTravel', 'TRV10011', 'TRVL', 'Travel');

		SVMXC__Installed_Product__c pendingIP = SMAX_PS_TestDataFactory.createIP('123456',acct,loc,'5545333',pd);
		pendingIP.SMAX_PS_Is_Pending_IP_Record__c = TRUE;
		update pendingIP;

		// Insert Work Order
		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createPendingIpWO(pendingIP, cont);

		Test.startTest();

		Account acct2 = SMAX_PS_TestDataFactory.createTestAccount('Another Pki Test', 'TESTX000222222','GB');
		SVMXC__Site__c loc2 = SMAX_PS_TestDataFactory.createTestLocation(acct2,'TestLocationSite2', '222222','LOC222');
		SVMXC__Installed_Product__c realIP = SMAX_PS_TestDataFactory.createIP('5555555',acct2,loc2,'5542222',pd);

		wo.SVMXC__Component__c = realIP.Id;
		update wo;

		Test.stopTest();

		SVMXC__Service_Order__c woResult = [SELECT Id, Name, SVMXC__Company__c, SVMXC__Site__c
			FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.assertEquals(acct2.Id, woResult.SVMXC__Company__c);
		System.assertEquals(loc2.Id, woResult.SVMXC__Site__c);
		
	}
	
	static testMethod void testTranslationLookup()
	{
		SMAX_PS_Translation__c t1 = SMAX_PS_TestDataFactory.createTestTranslation('English (US)', 'US');
		SMAX_PS_Translation__c t2 = SMAX_PS_TestDataFactory.createTestTranslation('Spanish (ES)', 'ES');

		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001','GB');
		Contact cont = SMAX_PS_TestDataFactory.createTestContact('Sir', 'Testalot', acct, 'TESTX00000001A');
		Product2 pd = SMAX_PS_TestDataFactory.createTestProduct('TestProduct', '106018','TST');
		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct,'TestLocationSite', '121212','LOC123');
		loc.SVMXC__Country__c = 'US';
		update loc;

		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('123456',acct,loc,'5545333',pd);

		Test.startTest();

		// Insert Work Order.. Translation should auto populate
		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createWO(ip, cont);

		Test.stopTest();

		SVMXC__Service_Order__c woResult = [SELECT Id, Name, SMAX_PS_Translation__c
			FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.assertEquals(t1.Id, woResult.SMAX_PS_Translation__c);

		// Simulate a User changing it manually.. shouldn't auto populate again
		woResult.SMAX_PS_Translation__c = t2.Id;
		update woResult;

		SVMXC__Service_Order__c woResult2 = [SELECT Id, Name, SMAX_PS_Translation__c
			FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.assertEquals(t2.Id, woResult2.SMAX_PS_Translation__c);
	}

	static testMethod void testAssignToTPV()
	{
		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001', 'GB');
		acct.PKI_SAP_City__c = 'Account City';
		update acct;

		Contact cont = SMAX_PS_TestDataFactory.createTestContact('Sir', 'Testalot', acct, 'TESTX00000001A');
		Product2 pd = SMAX_PS_TestDataFactory.createTestProduct('TestProduct', '106018', 'TST');

		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct, 'TestLocationSite', '121212', 'LOC123');

		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('123456', acct, loc, '5545333', pd);

		SVMXC__Service_Group_Members__c tech = SMAX_PS_TestDataFactory.createTestTechnician('TestTeam01', null, 'Test Tech1', 'TS12', 'T001');
		tech.SVMXC__Third_Party__c = true;
		update tech;

		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createWO(ip, cont);
		wo.SVMXC__Group_Member__c = tech.id;
		wo.SVMXC__Order_Status__c = 'Open';
		wo.SVMX_PS_External_ID__c = 'SAP1234567';
		update wo;

		SVMXC__Service_Order__c result = [SELECT Id, Name, OwnerId FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.assertNotEquals(UserInfo.getUserId(), result.OwnerId);
	}

	static testMethod void testWorkOrderAssignController()
	{
		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001','GB');
		acct.PKI_SAP_City__c = 'Account City';
		update acct;

		Contact cont = SMAX_PS_TestDataFactory.createTestContact('Sir', 'Testalot', acct, 'TESTX00000001A');
		Product2 pd = SMAX_PS_TestDataFactory.createTestProduct('TestProduct', '106018','TST');

		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct,'TestLocationSite', '121212','LOC123');

		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('123456',acct,loc,'5545333',pd);

		User techUser = new User(Id = UserInfo.getUserId());
		SVMXC__Service_Group_Members__c tech = SMAX_PS_TestDataFactory.createTestTechnician('TestTeam01', techUser, 'Test Tech1', 'TS12', 'T001');

		SVMXC__Service_Group_Members__c tpv = SMAX_PS_TestDataFactory.createTestTechnician('TestTeam01', null, 'Test TPV', 'TPV1', 'T001');
		tpv.SVMXC__Third_Party__c = true;
		update tpv;

		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createWO(ip, cont);
		wo.SVMXC__Order_Status__c = 'Open';
		wo.SVMXC__Billing_Type__c = 'Billable';
		wo.SVMX_PS_External_ID__c = 'SAP1234567';
		update wo;

		SVMXC__Service_Order__c updWO = [SELECT Id, Name, SVMX_PS_External_ID__c, SVMXC__Billing_Type__c, SVMXC__Order_Status__c 
											FROM SVMXC__Service_Order__c 
											WHERE Id = :wo.id LIMIT 1];
		System.debug('WO Name is ' + updWO.Name);

		SVMXC__Site__c updLoc = [SELECT Id, Name, SVMXC__City__c 
											FROM SVMXC__Site__c 
											WHERE Id = :loc.id LIMIT 1];

		SVMXC__Service_Group_Members__c updTech = [SELECT Id, Name 
											FROM SVMXC__Service_Group_Members__c
											WHERE Id = :tech.id LIMIT 1];											

		PageReference page = Page.SMAX_PS_WO_AssignGrid;

		SMAX_PS_WorkOrderAssignController controller = new SMAX_PS_WorkOrderAssignController();
		System.debug('Test WO Number is ' + updWO.Name);

		Test.startTest();
		controller.newFilter.SMAX_PS_Work_Order_Numbers__c = updWO.Name;
		controller.newFilter.SMAX_PS_Filter_On__c = 'Work Order: Number';
		controller.addFilters();

		controller.newFilter.SMAX_PS_Technician__c = tech.id;
		controller.newFilter.SMAX_PS_Filter_On__c = 'Technician: Name';
		controller.addFilters();
		controller.applyFilters();

		// This should assign the WO to the Tech
		SMAX_PS_WorkOrderAssignController.WorkOrderWrapper wow = controller.woList.get(0);
		wow.techId = tech.Id;
		controller.assign();

		controller.filterIdxToRemove = 1;
		controller.removeFilter();

		controller.newFilter.SMAX_PS_Technician__c = tpv.id;
		controller.newFilter.SMAX_PS_Filter_On__c = 'Technician: Name';
		controller.addFilters();
		controller.applyFilters();

		// This should assign the WO to the TPV, and delete the Tech's Event
		wow = controller.woList.get(0);
		wow.techId = tpv.Id;
		controller.assign();

		controller.filterIdxToRemove = 1;
		controller.removeFilter();

		controller.filterIdxToRemove = 0;
		controller.removeFilter();

		// Test all the other filters
		controller.newFilter.SMAX_PS_Work_Order_Numbers__c = updWO.SVMX_PS_External_ID__c;
		controller.newFilter.SMAX_PS_Filter_On__c = 'Work Order: SAP Service Order Number';
		controller.addFilters();
		controller.applyFilters();
		controller.removeFilter();

		controller.newFilter.SMAX_PS_Account__c = acct.id;
		controller.newFilter.SMAX_PS_Filter_On__c = 'Work Order: Account';
		controller.addFilters();
		controller.applyFilters();
		controller.removeFilter();
		controller.reset();	

		controller.newFilter.SMAX_PS_Filter_On__c = 'Work Order: Is Enterprise';
		controller.addFilters();
		controller.applyFilters();
		controller.reset();	

		controller.newFilter.SMAX_PS_Location__c = Loc.id;
		controller.newFilter.SMAX_PS_Filter_On__c = 'Work Order: Location';
		controller.addFilters();
		controller.applyFilters();
		controller.reset();	
		
		controller.newFilter.SMAX_PS_Order_Status__c = updWO.SVMXC__Order_Status__c;
		controller.newFilter.SMAX_PS_Filter_On__c = 'Work Order: Order Status';
		controller.addFilters();
		controller.applyFilters();
		controller.removeFilter();
		
		controller.newFilter.SMAX_PS_Technician__c = tech.id;
		controller.newFilter.SMAX_PS_Filter_On__c = 'Work Order: Technician';
		controller.addFilters();
		controller.applyFilters();
		controller.removeFilter();

		controller.newFilter.SMAX_PS_Customer_Number__c = acct.PKI_SAP_Customer_Number__c;
		controller.newFilter.SMAX_PS_Filter_On__c = 'Work Order: Customer Number';
		controller.addFilters();
		controller.applyFilters();
		controller.removeFilter();		

		controller.newFilter.SMAX_PS_Billing_Type__c = updWO.SVMXC__Billing_Type__c;
		controller.newFilter.SMAX_PS_Filter_On__c = 'Work Order: Billing Type';
		controller.addFilters();
		controller.applyFilters();
		controller.removeFilter();

		controller.newFilter.SMAX_PS_Account_City__c = acct.PKI_SAP_City__c;
		controller.newFilter.SMAX_PS_Filter_On__c = 'Work Order: Account City';
		controller.addFilters();
		controller.applyFilters();
		controller.removeFilter();	

		controller.newFilter.SMAX_PS_Service_Team__c = tech.SVMXC__Service_Group__c;
		controller.newFilter.SMAX_PS_Filter_On__c = 'Technician: Service Team';
		controller.addFilters();
		controller.applyFilters();
		controller.removeFilter();	

		controller.newFilter.SMAX_PS_Filter_On__c = 'Technician: Third Party';
		controller.addFilters();
		controller.applyFilters();
		controller.removeFilter();

		controller.saveView();
		controller.shareView();
		controller.reset();

		//page.getParameters().put(newFilter.SMAX_PS_Filter_On__c,'Work Order: Account');
		//Test.setCurrentPage(page);

		Test.stopTest();
	}
}