@isTest(seeAllData=true)
private class SMAX_PS_IntegrationError_UT {
	
	@isTest static void testRelatedElements() {

		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX0IE000001');
		Contact c = SMAX_PS_TestDataFactory.createTestContact('Testie', 'Testerson', acct, 'TEST000000101');
		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct, 'Test Location', 'TESTLOC001', 'TLC001');
		SVMXC__Site__c loc2 = SMAX_PS_TestDataFactory.createTestLocation(acct, 'Test Location2', 'TESTLOC002', 'TLC002');
		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('TESTX0000234001', acct, loc, 'MODS0010');

		Case cs = new Case(AccountId = acct.Id);
		insert cs;

		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createWO(ip, c);
		wo.SVMX_PS_External_ID__c = 'SON0001001';
		update wo;

        Id usageRecTypeId = SMAX_PS_Utility.getRecordType('SVMXC__Service_Order_Line__c', 'UsageConsumption').Id;
        SVMXC__Service_Order_Line__c wd = new SVMXC__Service_Order_Line__c(
            SVMXC__Service_Order__c=wo.Id,RecordTypeId=usageRecTypeId,SVMXC__Line_Status__c='Open');
        insert wd;

        Product2 prod = new Product2(Name='Test Product');
        insert prod;

        Id poRequestRecordTypeId = Schema.SObjectType.SVMXC__RMA_Shipment_Order__c.getRecordTypeInfosByName().get('Request').getRecordTypeId();
        SVMXC__RMA_Shipment_Order__c po = new SVMXC__RMA_Shipment_Order__c(RecordTypeId=poRequestRecordTypeId,
            SVMXC__Company__c=acct.Id, SVMXC__Contact__c=c.Id, SVMXC__Source_Location__c=loc.Id, Product__c=prod.Id,
            SVMXC__Expected_Receive_Date__c=date.today(), SVMXC__Order_Status__c='Submitted to ERP', SMAX_PS_ExternalId__c='PO10010010001');
        insert po;

        RecordType storageRecType = SMAX_PS_Utility.getRecordType('SVMXC__Site__c', 'SMAX_PS_Storage_Location');
        loc.RecordTypeId = storageRecType.Id;
        loc.SVMXC__Stocking_Location__c = TRUE;
        loc2.RecordTypeId = storageRecType.Id;
        loc2.SVMXC__Stocking_Location__c = TRUE;
        update new List<SVMXC__Site__c> { loc, loc2 };

		SVMXC__Stock_Transfer__c st = new SVMXC__Stock_Transfer__c(
			SVMXC__Source_Location__c=loc.id,
			SVMXC__Destination_Location__c=loc2.id,
			SMAX_PS_Status__c = 'Submitted');
		insert st;

		SMAX_PS_InventoryCount__c ic = new SMAX_PS_InventoryCount__c();
		ic.SMAX_PS_Status__c = 'Open';
		ic.SMAX_PS_RequestedFrom__c = loc.Id;
		insert ic;

		Id invDMRRecordTypeId = SMAX_PS_Utility.getRecordType('SVMXC__Proforma_Invoice__c', 'DMR').Id;
		SVMXC__Proforma_Invoice__c inv = new SVMXC__Proforma_Invoice__c(RecordTypeId=invDMRRecordTypeId, SVMXC__Status__c='Locked');
		inv.SMAX_PS_SAP_DMR_Number__c = 'DEF0001001001';
		insert inv;

		SVMXC__Service_Contract__c sc = SMAX_PS_TestDataFactory.createSvcMaintContract('SC-0001T001', acct.Id, Date.today(), Date.today().addYears(1));

		List<SMAX_PS_IntegrationError__c> ieList = new List<SMAX_PS_IntegrationError__c>();
		ieList.add(createError('ContactId', c.Id + ''));
		ieList.add(createError('ContactNumber', c.PKI_SAP_Contact_ID__c));
		ieList.add(createError('WorkOrderId', wo.Id + ''));
		ieList.add(createError('ServiceOrderNumber', wo.SVMX_PS_External_ID__c));
		ieList.add(createError('WorkDetailId', wd.Id + ''));
		ieList.add(createError('PartsOrderId', po.Id + ''));
		ieList.add(createError('PartsOrderNumber', po.SMAX_PS_ExternalId__c));
		ieList.add(createError('StockTransferId', st.Id + ''));
		ieList.add(createError('InventoryCountId', ic.Id + ''));
		ieList.add(createError('ServiceContractId', sc.Id + ''));
		ieList.add(createError('InvoiceId', inv.Id + ''));
		SMAX_PS_IntegrationError__c dmrError = createError('InvoiceNumber', inv.SMAX_PS_SAP_DMR_Number__c);
		dmrError.SMAX_PS_ErrorMessage__c = 'No New values found to update DMR: ' + inv.SMAX_PS_SAP_DMR_Number__c;
		ieList.add(dmrError);
		ieList.add(createError('CaseId', cs.Id + ''));

		insert ieList;

		SVMXC__Service_Order__c resultWO = [SELECT Id, Name, SMAX_PS_Last_Integration_Error__c FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.assertNotEquals(null, resultWO.SMAX_PS_Last_Integration_Error__c);

		SVMXC__Proforma_Invoice__c resultInv = [SELECT Id, Name, SVMXC__Status__c FROM SVMXC__Proforma_Invoice__c WHERE Id = :inv.Id];
		System.assertEquals('Open', resultInv.SVMXC__Status__c);

		SVMXC__RMA_Shipment_Order__c resultPO = [SELECT Id, Name, SVMXC__Order_Status__c FROM SVMXC__RMA_Shipment_Order__c WHERE Id = :po.Id];
		System.assertEquals('Error', resultPO.SVMXC__Order_Status__c);

//		SVMXC__Stock_Transfer__c resultST = [SELECT Id, Name, SMAX_PS_Status__c FROM SVMXC__Stock_Transfer__c WHERE Id = :st.Id];
//		System.assertEquals('Error', resultST.SMAX_PS_Status__c);

		SMAX_PS_IntegrationError__c ie1 = new SMAX_PS_IntegrationError__c();
		ie1.Id = ieList[0].Id;
		ie1.SMAX_PS_ErrorMessage__c = 'Updated Message';
		update ie1;

		delete ie1;
	}
	
	private static SMAX_PS_IntegrationError__c createError(String typeVal, String idVal)
	{
		SMAX_PS_IntegrationError__c ie = new SMAX_PS_IntegrationError__c();
		ie.SMAX_PS_RelatedElementType__c = typeVal;
		ie.SMAX_PS_RelatedElementIdentifier__c = idVal;
		ie.SMAX_PS_ErrorMessage__c = 'Test Error';
		return ie;
	}
}