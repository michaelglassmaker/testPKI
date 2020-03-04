@isTest
private class SMAX_PS_WorkOrderPricing_UT {
	
	static testMethod void testWorkOrderPricing()
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

        SVMXC.INTF_WebServicesDef.INTF_Response result1 = SMAX_PS_WorkOrderPricingService.getPriceWorkOrder(request);
        System.assertEquals(false, result1.success);

		loc.SMAX_PS_SalesOrg__c = 'TS10';
		update loc;

        SVMXC.INTF_WebServicesDef.INTF_Response result2 = SMAX_PS_WorkOrderPricingService.getPriceWorkOrder(request);
        System.assertEquals(true, result2.success);
	}
	
	static testMethod void testWorkOrderPricingSync()
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

        SVMXC.INTF_WebServicesDef.INTF_Response result1 = SMAX_PS_WorkOrderPricingService.getPriceWorkOrderSync(request);
        System.assertEquals(false, result1.success);

		loc.SMAX_PS_SalesOrg__c = 'TS10';
		update loc;

        SVMXC.INTF_WebServicesDef.INTF_Response result2 = SMAX_PS_WorkOrderPricingService.getPriceWorkOrderSync(request);
        System.assertEquals(true, result2.success);
	}

	static testMethod void testWorkOrderPricingCDE()
	{
		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001');
		Contact c = SMAX_PS_TestDataFactory.createTestContact('Testie', 'Testerson', acct, 'TEST000000101');
		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct, 'Test Location', 'TESTLOC001', 'TSTC01');
		loc.SMAX_PS_SalesOrg__c = 'TS10';
		update loc;

		Product2 instrumentProd = SMAX_PS_TestDataFactory.createTestProduct('TestInstrument', 'INS10010', 'INST', null);
		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('TESTX0000234001', acct, loc, 'TST001', instrumentProd);
		Product2 laborProd = SMAX_PS_TestDataFactory.createTestProduct('TestLabor', 'LAB10010', 'LABR', 'Labor');
		Product2 travelProd = SMAX_PS_TestDataFactory.createTestProduct('TestTravel', 'TRV10010', 'TRVL', 'Travel');
		Product2 partsProd = SMAX_PS_TestDataFactory.createTestProduct('TestConsumable', 'CON10010', 'CONS', 'Consumable');

		BD_Contract_Discount_Exception__c cde1 = new BD_Contract_Discount_Exception__c(BD_Parts_Product__c = partsProd.Id,
			BD_Discount_Type__c = 'Other Parts', BD_Instrument_Product__c = null,
			BD_Sales_Org__c = 'TS10', BD_SAP_Activity_Type__c = 'REP');
		BD_Contract_Discount_Exception__c cde2 = new BD_Contract_Discount_Exception__c(BD_Parts_Product__c = partsProd.Id,
			BD_Discount_Type__c = 'Service Parts', BD_Instrument_Product__c = instrumentProd.Id,
			BD_Sales_Org__c = 'TS10', BD_SAP_Activity_Type__c = 'REP');
		BD_Contract_Discount_Exception__c cde3 = new BD_Contract_Discount_Exception__c(BD_Parts_Product__c = partsProd.Id,
			BD_Discount_Type__c = 'Labor', BD_Instrument_Product__c = null,
			BD_Sales_Org__c = 'TS10', BD_SAP_Activity_Type__c = 'PM');
		insert new List<BD_Contract_Discount_Exception__c> { cde1, cde2, cde3 };

//		Map<Id, Product2> productMap = new Map<Id, Product2>([SELECT Id, Name,
//				SVMXC__Product_Type__c, SMAX_PS_Discount_Type__c,
//		(SELECT Id, BD_Discount_Type__c, BD_Instrument_Product__c, BD_Sales_Org__c, BD_SAP_Activity_Type__c
//		FROM Parts_Contract_Discount_Exceptions__r
//		WHERE BD_SAP_Activity_Type__c = 'REP'
//		AND (BD_Sales_Org__c = NULL OR BD_Sales_Org__c = 'TS10')
//		AND (BD_Instrument_Product__c = NULL OR BD_Instrument_Product__c = :instrumentProd.Id)
//		ORDER BY BD_Sales_Org__c NULLS LAST, BD_Instrument_Product__c NULLS LAST)
//		FROM Product2 WHERE Id = :partsProd.Id]);
//
//		for (Product2 prod : productMap.values())
//		{
//			System.debug('^^ FOUND ' + prod.Parts_Contract_Discount_Exceptions__r.size() + ' Contract Discount Exceptions!');
//			System.debug('^^ CDEs = ' + prod.Parts_Contract_Discount_Exceptions__r);
//		}

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

		SVMXC.INTF_WebServicesDef.INTF_Response result2 = SMAX_PS_WorkOrderPricingService.getPriceWorkOrder(request);
		System.assertEquals(true, result2.success);

		SVMXC__Service_Order_Line__c partsResult = [SELECT Id, Name, SVMXC__Product__c, BD_Discount_Type__c, SMAX_PS_ContractPercentDiscount__c
			FROM SVMXC__Service_Order_Line__c WHERE Id = :wd3.Id];
		System.assertEquals(cde2.BD_Discount_Type__c, partsResult.BD_Discount_Type__c);
		System.assertEquals(ent.SMAX_PS_ServicePartsDiscountCovered__c, partsResult.SMAX_PS_ContractPercentDiscount__c);

	}


}