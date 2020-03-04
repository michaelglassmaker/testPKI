/*
	Test Class for  SMAX_PS_InventoryManager
	Client      :   PerkinElmer
	Created by  :   Veerendra on 2017-09-11
*/
@isTest(seeAllData=false)
public class SMAX_PS_InventoryManager_UT
{         
	static testMethod void createTestData()
	{   
		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001');
		Contact cont = SMAX_PS_TestDataFactory.createTestContact('Sir', 'Testalot', acct, 'TESTX00000001A');

		// Insert source location
		SVMXC__Site__c sloc = new SVMXC__Site__c(
							Name='Test source Location',
							SVMXC__Street__c='123 street',
							SVMXC__City__c='123 city',
							SVMXC__State__c='123 state',
							SVMXC__Zip__c='12345',
							SVMXC__Country__c='United States',
							SVMXC__Stocking_Location__c=true);
		insert sloc;
		// Insert destination location
		SVMXC__Site__c dloc = new SVMXC__Site__c(
							Name='Test destination Location',
							SVMXC__Street__c='456 street',
							SVMXC__City__c='456 city',
							SVMXC__State__c='456 state',
							SVMXC__Zip__c='45678',
							SVMXC__Country__c='United States',
							SVMXC__Stocking_Location__c=true);
		insert dloc;

		Product2 p = SMAX_PS_TestDataFactory.createTestProduct('Test Product', 'TPRD1001', 'Test');

		// insert Product Stock
		SVMXC__Product_Stock__c ps = new SVMXC__Product_Stock__c(
							SVMXC__Partner_Account__c=acct.id,
							SVMXC__Partner_Contact__c=cont.id,
							SVMXC__Location__c=sloc.id,
							SVMXC__Product__c = p.Id,
							SMAX_PS_CompletedTxnNum__c='tran');
		insert ps;

		// insert Product Serial
		SVMXC__Product_Serial__c ss = new SVMXC__Product_Serial__c(
							SVMXC__Product_Stock__c=ps.id);
		insert ss;

		// update Product stock
		ps.SMAX_PS_CompletedTxnNum__c='tran1';
		update ps;

		// insert Stock Transfer
		 SVMXC__Stock_Transfer__c st = new SVMXC__Stock_Transfer__c(
							SVMXC__Source_Location__c=sloc.id,
							SVMXC__Destination_Location__c=dloc.id);
		insert st;

		// Update Stock Transfer
		st.SMAX_PS_Status__c='Submitted';
		update st;

		// insert Inventory Count
		SMAX_PS_InventoryCount__c ic = new SMAX_PS_InventoryCount__c();
		insert ic;

		// Update Inventory Count
		ic.SMAX_PS_Status__c='Submitted';
		update ic;
	}

	static testMethod void testStockCompletedTxn()
	{
		Account acct = SMAX_PS_TestDataFactory.createTestAccount('Test Acct', 'TST1001001');
		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct, 'Test Loc', 'TLOC0010101', 'TST001');
		Product2 p = SMAX_PS_TestDataFactory.createTestProduct('Test Product', 'TPRD1001', 'Test');

		SVMXC__Product_Stock__c ps1 = SMAX_PS_TestDataFactory.createTestProductStock(loc, p, 'Available', 0);
		SVMXC__Product_Stock__c ps2 = SMAX_PS_TestDataFactory.createTestProductStock(loc, p, 'In Transit', 0);
		SVMXC__Product_Stock__c ps3 = SMAX_PS_TestDataFactory.createTestProductStock(loc, p, 'Returned', 1);
		SVMXC__Product_Stock__c ps4 = SMAX_PS_TestDataFactory.createTestProductStock(loc, p, 'Consumed', 0);

		SVMXC__Product_Serial__c serial = new SVMXC__Product_Serial__c();
		serial.SVMXC__Product_Stock__c = ps4.Id;
		serial.SMAX_PS_SerialNum__c = 'SN100192993';
		insert serial;

		Test.startTest();

		List<SVMXC__Product_Stock__c> stock = new List<SVMXC__Product_Stock__c> { ps1, ps2, ps3, ps4 };
		for (SVMXC__Product_Stock__c ps : stock)
			ps.SMAX_PS_CompletedTxnNum__c = '111';
		update stock;

		Test.stopTest();

		Map<Id, SVMXC__Product_Stock__c> result = new Map<Id, SVMXC__Product_Stock__c>([SELECT Id, Name FROM SVMXC__Product_Stock__c WHERE Id IN :stock]);
		System.assertNotEquals(null, result.get(ps1.Id)); // Should be saved due to 'Available'
		System.assertNotEquals(null, result.get(ps3.Id)); // Should be saved due to Qty > 0
		System.assertNotEquals(null, result.get(ps4.Id)); // Should be saved due to child Serial
		System.assertEquals(null, result.get(ps2.Id));  // This one should have been deleted
	}

	static testMethod void testInventoryCount()
	{
		// SVMXCFG-647 - Cannot create new User due to managed package error
		//User techUser = SMAX_PS_TestDataFactory.createTestUser('testtech');
		User techUser = new User(Id = UserInfo.getUserId());
		SVMXC__Service_Group_Members__c tech = SMAX_PS_TestDataFactory.createTestTechnician('TestTeam01', techUser, 'Test Tech1', 'TS12', 'T001');

		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001');
		Contact c = SMAX_PS_TestDataFactory.createTestContact('Testie', 'Testerson', acct, 'TEST000000101');
		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct, 'Test Location', 'TESTLOC001', 'TSTC01');
		loc.SVMXC__Service_Engineer__c = techUser.Id;
		update loc;

		Product2 p = SMAX_PS_TestDataFactory.createTestProduct('Test Product', 'TPRD1001', 'Test');
		SVMXC__Product_Stock__c ps1 = SMAX_PS_TestDataFactory.createTestProductStock(loc, p, 'Available', 4);

		Test.startTest();

		// Fill in SMAX_PS_RequestedFrom__c (Location)
		SMAX_PS_InventoryCount__c ic = new SMAX_PS_InventoryCount__c();
		ic.SMAX_PS_Status__c = 'Open';
		ic.SMAX_PS_RequestedFrom__c = loc.Id;
		insert ic;

		// Assert SMAX_PS_RequestedTechnician__c is not blank (Technician)
		SMAX_PS_InventoryCount__c icResult = [SELECT Id, Name, SMAX_PS_RequestedTechnician__c FROM SMAX_PS_InventoryCount__c WHERE Id = :ic.Id];
		System.assertEquals(tech.Id, icResult.SMAX_PS_RequestedTechnician__c);

		// Lines.. Assert SMAX_PS_ProductStock__c is auto-filled based on SMAX_PS_Product__c
		SMAX_PS_InventoryCountLine__c line1 = new SMAX_PS_InventoryCountLine__c();
		line1.SMAX_PS_InventoryCount__c = ic.Id;
		line1.SMAX_PS_Product__c = p.Id;
		insert line1;

		SMAX_PS_InventoryCountLine__c lineResult = [SELECT Id, SMAX_PS_ProductStock__c FROM SMAX_PS_InventoryCountLine__c WHERE Id = :line1.Id];
		System.assertEquals(ps1.Id, lineResult.SMAX_PS_ProductStock__c);

		// Change SMAX_PS_Status__c == 'Confirmed' .. send event
		ic.SMAX_PS_Status__c = 'Confirmed';
		update ic;

		Test.stopTest();
	}

}