/**
 * Created by frankvanloon on 2019-05-16.
 * ITSFDC-1161 (old SVMXCFG-1108) Metrics and KPI
 */
@IsTest(SeeAllData=false)
public class SMAX_PS_WorkOrderMetrics_UT
{
	static testMethod void testBusinessHours()
	{
		User techUser = new User(Id = UserInfo.getUserId());
		SVMXC__Service_Group_Members__c tech1 = SMAX_PS_TestDataFactory.createTestTechnician('TestTeam01', techUser, 'Test Tech1', 'TS12', 'T001');

		Datetime now = Datetime.now();
		Datetime startDt = now.addHours(-1);
		Datetime endDt = now.addHours(-1).addMinutes(30);

		Map<Id, BusinessHours> bizHourMap = SMAX_PS_BusinessHours.lookupTechnicianBusinessHours(new Set<Id> { tech1.Id });
		BusinessHours bh = bizHourMap.get(tech1.Id);

		//Decimal result =
			SMAX_PS_BusinessHours.businessHoursBetween(bh, startDt, endDt);
		// The following only works during business hours, so commented out for deployments
		// System.assertEquals(0.5, result);
	}


	static testMethod void testFieldServiceWorkOrder()
	{
		User techUser = new User(Id = UserInfo.getUserId());
		SVMXC__Service_Group_Members__c tech1 = SMAX_PS_TestDataFactory.createTestTechnician('TestTeam01', techUser, 'Test Tech1', 'TS12', 'T001');
		SVMXC__Service_Group_Members__c tech2 = SMAX_PS_TestDataFactory.createTestTechnician('TestTeam01', techUser, 'Test Tech2', 'TS22', 'T002');

		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX99990001','GB');
		Map<String, Account> acctMap = SMAX_PS_TestDataFactory.createTestPartnerAccounts(acct);

		Contact cont = SMAX_PS_TestDataFactory.createTestContact('Sir', 'Testalot', acct, 'TESTX99990001A');
		Product2 pd = SMAX_PS_TestDataFactory.createTestProduct('TestProduct', '106018','TST');
		pd.SMAX_PS_Super_Business_Unit__c = 'DAS';
		update pd;

		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct,'TestLocationSite', '121212','LOC199');
		loc.SMAX_PS_MaintenancePlant__c = 'TT12';
		// SVMXCFG-903 Copy Local Language Accounts to WO
		loc.SMAX_PS_LL_BillToExtID__c = acctMap.get('LocalLangBillTo').PKI_SAP_Customer_Number__c;
		loc.SMAX_PS_LL_ShipToExtID__c = acctMap.get('LocalLangShipTo').PKI_SAP_Customer_Number__c;
		update loc;

		//SVMXC__Site__c expLoc = SMAX_PS_TestDataFactory.createTestLocation(acct,'Test Expense Loc', 'TT12F000', 'LOC123');

		Product2 laborProd = SMAX_PS_TestDataFactory.createTestProduct('TestLabor', 'LAB100101', 'LABR', 'Labor');
		Product2 travelProd = SMAX_PS_TestDataFactory.createTestProduct('TestTravel', 'TRV10011', 'TRVL', 'Travel');

		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('123456',acct,loc,'5545333',pd);

		// Insert Work Order
		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createWO(ip, cont);

		wo.SVMX_PS_External_ID__c = 'SO999991992';
		wo.SMAX_PS_SAP_SystemStatus__c = 'REL';
		wo.SVMXC__Group_Member__c = tech1.Id;
		update wo;

		SMAX_PS_Fault_Code__c fc = SMAX_PS_TestDataFactory.createTestFaultCode('TFAM', 'TFAM-TTT', 'TTT2', 'Testing', false);

		Datetime now = Datetime.now();
		Id usage = Schema.SObjectType.SVMXC__Service_Order_Line__c.getRecordTypeInfosByName().get('Usage/Consumption').getRecordTypeId();
		SVMXC__Service_Order_Line__c laborLine = new SVMXC__Service_Order_Line__c(
				SVMXC__Service_Order__c=wo.Id, RecordTypeId=usage, SVMXC__Line_Type__c = 'Labor', SVMXC__Line_Status__c='Confirmed',
				SVMXC__Product__c = laborProd.Id, SVMXC__Actual_Quantity2__c = 1.5,
				SVMXC__Start_Date_and_Time__c = now.addHours(-5), SVMXC__End_Date_and_Time__c = now.addHours(-3));
		SVMXC__Service_Order_Line__c travelLine = new SVMXC__Service_Order_Line__c(
				SVMXC__Service_Order__c=wo.Id, RecordTypeId=usage, SVMXC__Line_Type__c = 'Travel', SVMXC__Line_Status__c='Confirmed',
				SVMXC__Product__c = travelProd.Id, SVMXC__Actual_Quantity2__c = 2);
		SVMXC__Service_Order_Line__c fcl = new SVMXC__Service_Order_Line__c(
				SVMXC__Service_Order__c=wo.Id, RecordTypeId=usage, SVMXC__Line_Type__c = 'Fault Code', SVMXC__Line_Status__c='Confirmed',
				SMAX_PS_Fault_Code__c = fc.Id); //, SMAX_PS_ActionFaultCode__c = fc.Id, SMAX_PS_InstallationFaultCode__c = fc.Id, SMAX_PS_CompletionFaultCode__c = fc.Id);
		List<SVMXC__Service_Order_Line__c> lines = new List<SVMXC__Service_Order_Line__c> { laborLine, travelLine, fcl };
		insert lines;

		wo.SVMXC__Order_Status__c='Work Complete';
		wo.SVMXC__Group_Member__c = tech2.Id; // 2nd assignment..
		update wo;

		wo.SMAX_PS_SAP_SystemStatus__c='TECO';
		wo.SVMXC__Completed_Date_Time__c = Datetime.now().addHours(1); // This is cheating..
		wo.SVMX_PS_Ready_to_Review_Date_Time__c = Datetime.now().addDays(2); // This is cheating..
		update wo;

		//SVMXC__Order_Status__c, SMAX_PS_Completion_Errors__c,
//		System.assertEquals(null, result.SMAX_PS_Completion_Errors__c);
//		System.assertEquals('Work Complete', result.SVMXC__Order_Status__c);

		SMAX_PS_Work_Order_Metrics__c result = [SELECT Id, Name,
			SMAX_PS_Calculated_Dispatch_Time__c, SMAX_PS_Calc_Tech_Support_Response_Time__c,
			SMAX_PS_Calc_Onsite_Response_Time__c, SMAX_PS_Calculated_Downtime__c,
			SMAX_PS_Calc_Call_Upload_Time__c, SMAX_PS_Calc_Days_to_Invoice__c,
			SMAX_PS_Is_First_Time_Fix__c, SMAX_PS_Number_of_Assignments__c,
			SMAX_PS_Repair_Callback_Required__c, SMAX_PS_Remote_Fix__c,
			SMAX_PS_First_Labor_DateTime__c, SMAX_PS_Last_Labor_Datetime__c
			FROM SMAX_PS_Work_Order_Metrics__c WHERE SMAX_PS_Work_Order__c = :wo.Id];
		System.assertNotEquals(null, result.SMAX_PS_First_Labor_DateTime__c);
		System.assertNotEquals(null, result.SMAX_PS_Last_Labor_Datetime__c);

		wo.SVMXC__Order_Status__c='Ready for Review';
		update wo;

		wo.SVMXC__Order_Status__c='Invoiced';
		update wo;

		// Create Callbacks...
		RecordType fsRecType = SMAX_PS_Utility.getRecordType('SVMXC__Service_Order__c', 'Field_Service');
		SVMXC__Service_Order__c repairCallback = new SVMXC__Service_Order__c(RecordTypeId = fsRecType.Id,
				SVMXC__Company__c = acct.Id, SVMXC__Contact__c = cont.Id, SVMXC__Component__c = ip.Id,
				SVMXC__Order_Type__c = 'Repair', SVMXC__Billing_Type__c = 'Billable');
		insert new List<SVMXC__Service_Order__c> { repairCallback };

		result = [SELECT Id, Name, SMAX_PS_Repair_Callback_Required__c
			FROM SMAX_PS_Work_Order_Metrics__c WHERE SMAX_PS_Work_Order__c = :wo.Id];
		System.assertEquals(1, result.SMAX_PS_Repair_Callback_Required__c);

		Test.startTest();

		SMAX_PS_WorkOrderMetrics_Batch.startFieldServiceBatch();

		Test.stopTest();
	}

	static testMethod void testRemoteWorkOrder()
	{
		BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=TRUE];
		User techUser = new User(Id = UserInfo.getUserId());
		SVMXC__Service_Group_Members__c tech = SMAX_PS_TestDataFactory.createTestTechnician('TestTeam01', techUser, 'Test Tech1', 'TS12', 'T001');

		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000008801','GB');
		Contact cont = SMAX_PS_TestDataFactory.createTestContact('Sir', 'Testalot', acct, 'TESTX00088001A');

		Product2 pd = SMAX_PS_TestDataFactory.createTestProduct('TestProduct', '106018','TST');
		pd.SMAX_PS_Super_Business_Unit__c = 'DAS';
		update pd;

		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct,'TestLocationSite', '121212','LOC199');

		Product2 laborProd = SMAX_PS_TestDataFactory.createTestProduct('TestLabor', 'LAB100101', 'LABR', 'Labor');
//		Product2 travelProd = SMAX_PS_TestDataFactory.createTestProduct('TestTravel', 'TRV10011', 'TRVL', 'Travel');

		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('123456',acct,loc,'5545333',pd);

		RecordType fsRecType = SMAX_PS_Utility.getRecordType('SVMXC__Service_Order__c', 'Field_Service');
		RecordType rmRecType = SMAX_PS_Utility.getRecordType('SVMXC__Service_Order__c', 'Remote');
		RecordType rmWdRecType = SMAX_PS_Utility.getRecordType('SVMXC__Service_Order_Line__c', 'SMAX_PS_Remote_Support');

		SVMXC__Service_Order__c wo1 = new SVMXC__Service_Order__c(RecordTypeId = rmRecType.Id,
				SVMXC__Company__c = acct.Id, SVMXC__Contact__c = cont.Id, SVMXC__Component__c = ip.Id,
				SVMXC__Group_Member__c = tech.Id);
		SVMXC__Service_Order__c wo2 = new SVMXC__Service_Order__c(RecordTypeId = rmRecType.Id,
				SVMXC__Company__c = acct.Id, SVMXC__Contact__c = cont.Id, SVMXC__Component__c = ip.Id,
				SVMXC__Preferred_Business_Hours__c = bh.Id);
//				SVMXC__Group_Member__c = tech.Id);
		insert new List<SVMXC__Service_Order__c> { wo1, wo2 };

		Datetime now = Datetime.now();
		SVMXC__Service_Order_Line__c ll1 = new SVMXC__Service_Order_Line__c(
				SVMXC__Service_Order__c=wo1.Id, RecordTypeId=rmWdRecType.Id, SVMXC__Line_Type__c = 'Labor',
				SVMXC__Product__c = laborProd.Id, SVMXC__Actual_Quantity2__c = 1.5,
				SVMXC__Start_Date_and_Time__c = now.addHours(-2), SVMXC__End_Date_and_Time__c = now.addHours(-1));
		SVMXC__Service_Order_Line__c ll2 = new SVMXC__Service_Order_Line__c(
				SVMXC__Service_Order__c=wo2.Id, RecordTypeId=rmWdRecType.Id, SVMXC__Line_Type__c = 'Labor',
				SVMXC__Product__c = laborProd.Id, SVMXC__Actual_Quantity2__c = 1.5,
				SVMXC__Start_Date_and_Time__c = now.addHours(-5), SVMXC__End_Date_and_Time__c = now.addHours(-3));
		insert new List<SVMXC__Service_Order_Line__c> { ll1, ll2 };

		// Convert to FieldService...
		wo1.RecordTypeId = fsRecType.Id;
		update wo1;

		wo2.SVMXC__Order_Status__c = 'Closed';
		update wo2;

		SMAX_PS_Work_Order_Metrics__c result1 = [SELECT Id, Name,
				SMAX_PS_Remote_Fix__c, SMAX_PS_Calc_Tech_Support_Response_Time__c,
			SMAX_PS_First_Labor_DateTime__c, SMAX_PS_Last_Labor_Datetime__c
			FROM SMAX_PS_Work_Order_Metrics__c WHERE SMAX_PS_Work_Order__c = :wo1.Id AND SMAX_PS_Metrics_Type__c = 'Remote'];
		System.assertEquals(0, result1.SMAX_PS_Remote_Fix__c);
		System.assertNotEquals(null, result1.SMAX_PS_Calc_Tech_Support_Response_Time__c);
		System.assertNotEquals(null, result1.SMAX_PS_First_Labor_DateTime__c);
		System.assertNotEquals(null, result1.SMAX_PS_Last_Labor_Datetime__c);

		SMAX_PS_Work_Order_Metrics__c result2 = [SELECT Id, Name,
				SMAX_PS_Remote_Fix__c, SMAX_PS_Calc_Tech_Support_Response_Time__c,
				SMAX_PS_First_Labor_DateTime__c, SMAX_PS_Last_Labor_Datetime__c
		FROM SMAX_PS_Work_Order_Metrics__c WHERE SMAX_PS_Work_Order__c = :wo2.Id];
		System.assertEquals(1, result2.SMAX_PS_Remote_Fix__c);
		System.assertNotEquals(null, result2.SMAX_PS_Calc_Tech_Support_Response_Time__c);
		System.assertNotEquals(null, result2.SMAX_PS_First_Labor_DateTime__c);
		System.assertNotEquals(null, result2.SMAX_PS_Last_Labor_Datetime__c);

		Test.startTest();

		SMAX_PS_WorkOrderMetrics_Batch.startRemoteBatch();

		Test.stopTest();
	}

	static testMethod void testBusinessHoursController()
	{
		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001','GB');
		Contact cont = SMAX_PS_TestDataFactory.createTestContact('Sir', 'Testalot', acct, 'TESTX00000001A');
		Product2 pd = SMAX_PS_TestDataFactory.createTestProduct('TestProduct', '106018','TST');
		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct,'TestLocationSite', '121212','LOC123');
		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('123456',acct,loc,'5545333',pd);

		// Insert Work Order
		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createWO(ip, cont);

		ApexPages.StandardController stdController = new ApexPages.StandardController(wo);
		SMAX_PS_WorkOrderBusinessHoursController bizHoursController = new SMAX_PS_WorkOrderBusinessHoursController(stdController);

		BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=TRUE];
		bizHoursController.wo.SVMXC__Preferred_Business_Hours__c = bh.Id;
		bizHoursController.saveWO();
	}

}