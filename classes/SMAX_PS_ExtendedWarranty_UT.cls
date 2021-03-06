/**
 * Created by frankvanloon on 2019-11-11.
 */
@IsTest
private class SMAX_PS_ExtendedWarranty_UT {

	@IsTest
	static void testExtendedCoverage()
	{
		// Insert Product
		Product2 eqProd = new Product2(Name='Test Equipment Product', Description='Test Equipment Product Description',
				Partnum__c='TESTT00100101', SVMXC__Product_Type__c='Service Parts', SMAX_PS_ActivityType__c='ACT001');
		Product2 part1 = new Product2(Name='Test Part', Description='Test Part Description',
				Partnum__c='TESTP00100101', SVMXC__Product_Type__c='Consumable');
		Product2 part2 = new Product2(Name='Test Part 2', Description='Test Part 2 Description',
				Partnum__c='TESTP00200202', SVMXC__Product_Type__c='Consumable');
		insert new List<Product2> { eqProd, part1, part2 };

		BD_Extended_Warranty_Part__c ewp1a = new BD_Extended_Warranty_Part__c(BD_Equipment_Product__c = eqProd.Id,
				BD_Last_Txn_Number__c = 'ABC', BD_Sales_Org__c = 'TS11', BD_External_Key__c = eqProd.Partnum__c+'-TS11-'+part1.Partnum__c,
				BD_Covered_Part__c = part1.Id, BD_Extended_Months__c = 9);
		BD_Extended_Warranty_Part__c ewp1b = new BD_Extended_Warranty_Part__c(BD_Equipment_Product__c = eqProd.Id,
				BD_Last_Txn_Number__c = 'ABC', BD_Sales_Org__c = 'XX11', BD_External_Key__c = eqProd.Partnum__c+'-XX11-'+part1.Partnum__c,
				BD_Covered_Part__c = part1.Id, BD_Extended_Months__c = 18);
		BD_Extended_Warranty_Part__c ewp2 = new BD_Extended_Warranty_Part__c(BD_Equipment_Product__c = eqProd.Id,
				BD_Last_Txn_Number__c = 'ABC', BD_Sales_Org__c = null, BD_External_Key__c = eqProd.Partnum__c+'-*-'+part2.Partnum__c,
				BD_Covered_Part__c = part2.Id, BD_Extended_Months__c = 15);
		insert new List<BD_Extended_Warranty_Part__c> { ewp1a, ewp1b, ewp2 };

		String modelSeries = 'TST001';
		String locCode = 'TSTC01';

		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001');
		Contact c = SMAX_PS_TestDataFactory.createTestContact('Testie', 'Testerson', acct, 'TEST000000101');
		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct, 'Test Location', 'TESTLOC001', locCode);
		loc.SMAX_PS_SalesOrg__c = 'XX11';
		update loc;
		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('TESTX0000234001', acct, loc, modelSeries, eqProd);

		Date startDate = System.today().addYears(-2);
		Date endDate = startDate.addMonths(12);
		SVMXC__Service_Contract__c sc = SMAX_PS_TestDataFactory.createSvcMaintContract('ExpiredWarranty', ip.SVMXC__Company__c, startDate, endDate);
		sc.SMAX_PS_ContractType__c = 'ZW01';
		update sc;
		SVMXC__Service_Contract__c item = SMAX_PS_TestDataFactory.createContractItem(sc, 'ExpiredWarrantyItem', startDate, endDate);
		SVMXC__Service_Contract_Products__c cp = SMAX_PS_TestDataFactory.createCoveredIP(item, startDate, endDate, ip);
		SVMXC__Service_Contract_Services__c ent1 = SMAX_PS_TestDataFactory.createEntitlement(item,'REP', 5, 0);
		SVMXC__Service_Contract_Services__c ent2 = SMAX_PS_TestDataFactory.createEntitlement(item,'ZZZ', 0, 0);

		Test.startTest();

		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createWO(ip, c);

		List<BD_Extended_Warranty_Coverage__c> results = [SELECT Id, Name, BD_Covered_Part__c, BD_Covered_Until__c,
				BD_Warranty_Contract__c, BD_Warranty_Contract_Item__c, BD_Warranty_Work_Order__c
			FROM BD_Extended_Warranty_Coverage__c WHERE BD_Parent_Work_Order__c = :wo.Id];
		System.assertEquals(2, results.size());

		// NEW: Update Coverage record.. let WO auto-create!
		results[0].BD_Create_Warranty_Work_Order__c = TRUE;
		update results[0];

		// Create a Warranty WO from one of the "coverage" lines (to mimic the SFM).. verify "complete coverage" results
//		SVMXC__Service_Order__c wo2 = new SVMXC__Service_Order__c();
//		wo2.SVMXC__Component__c = ip.id;
//		wo2.SVMXC__Billing_Type__c = 'Contract';
//		wo2.SVMXC__Order_Type__c = 'Repair';
//		wo2.SVMXC__Company__c = ip.SVMXC__Company__c;
//		wo2.SVMXC__Site__c = ip.SVMXC__Site__c;
//		wo2.SVMXC__Scheduled_Date__c = startDate.addDays(1);
//		wo2.SVMXC__Contact__c = c.Id;
//		wo2.SVMXC__Service_Contract__c = results[0].BD_Warranty_Contract__c;
//		wo2.SMAX_PS_ContractItem__c = results[0].BD_Warranty_Contract_Item__c;
//		insert wo2;

		SVMXC__Service_Order__c result = [SELECT Id, Name, SVMXC__Service_Contract__c, SMAX_PS_ContractItem__c,
				SMAX_PS_ContractEntitlement__c, SMAX_PS_CoveredProduct__c, SVMXC__Auto_Entitlement_Status__c,
				SVMXC__Is_Entitlement_Performed__c, SVMXC__Entitlement_Type__c, SVMXC__Entitlement_Notes__c,
				SVMXC__Problem_Description__c
		FROM SVMXC__Service_Order__c WHERE SVMX_PS_Parent_Work_Order__c = :wo.Id];

		System.debug('COMPLETE-ENTITLE RESULT WO: ' + result);
		System.assertEquals(true, result.SVMXC__Is_Entitlement_Performed__c);
		System.assertEquals(item.SVMX_PS_Parent_Contract__c, result.SVMXC__Service_Contract__c);
		System.assertEquals(item.Id, result.SMAX_PS_ContractItem__c);
		System.assertEquals(ent2.Id, result.SMAX_PS_ContractEntitlement__c);
		System.assertEquals(cp.Id, result.SMAX_PS_CoveredProduct__c);
		System.assertEquals('Success', result.SVMXC__Auto_Entitlement_Status__c);
		System.assertEquals('SAP', result.SVMXC__Entitlement_Type__c);
		//System.assertEquals(true, result.SVMXC__Entitlement_Notes__c.contains('Matching to Entitlement by Qty'));

		Test.stopTest();
	}
}