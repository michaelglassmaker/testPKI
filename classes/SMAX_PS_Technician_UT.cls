@isTest(seeAllData=false)
private class SMAX_PS_Technician_UT 
{
	
	// SVMXCFG-647 - Added seeAllData=true to prevent managed package error on createTestUser(...)
	@isTest(seeAllData=true)
	static void testLocationLookup() 
	{
		Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User']; 
		User techUser = new User(alias = 'testies', email = 'testiesMail@yahoo.com',
			emailEncodingKey = 'UTF-8', languageLocaleKey = 'en_US', firstname = 'Testopher', lastName = 'Testofferson',
			localeSidKey = 'en_US', timeZoneSidKey = 'America/Los_Angeles', profileId = p.Id,
			/*PKI_GBL_Job_Family__c = 'Service',*/ username = 'testiesMail@yahoo.com', communityNickname = 'TestieBoi');
		insert techUser;

		Test.startTest();

		SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
		team.Name = 'Test Team';
		insert team;

		SVMXC__Service_Group_Members__c tech = new SVMXC__Service_Group_Members__c();
		tech.SMAX_PS_Plant__c = 'TS12';
		tech.SMAX_PS_LocationCode__c = 'T001';
		tech.SVMXC__Service_Group__c = team.Id;

		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001');
		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct, 'ParentLocTest', 
			tech.SMAX_PS_Plant__c + tech.SMAX_PS_LocationCode__c, tech.SMAX_PS_LocationCode__c);

		tech.SVMXC__Salesforce_User__c = techUser.Id;
		insert tech;

		SMAX_PS_Geography_Technician__c geoTech1 = new SMAX_PS_Geography_Technician__c();
		geoTech1.SMAX_PS_Technician__c = tech.Id;
		geoTech1.SMAX_PS_Location__c = 'TST10';

		SMAX_PS_Geography_Technician__c geoTech2 = new SMAX_PS_Geography_Technician__c();
		geoTech2.SMAX_PS_Technician__c = tech.Id;
		geoTech2.SMAX_PS_Location__c = 'TST12';

		insert new List<SMAX_PS_Geography_Technician__c> { geoTech1, geoTech2 };

		Test.stopTest();

		// Validate that the tech.SVMXC__Inventory_Location__c is filled in
		tech = [SELECT Id, Name, SMAX_PS_Plant__c, SMAX_PS_LocationCode__c, SVMXC__Inventory_Location__c, 
			SVMXC__Salesforce_User__c, SMAX_PS_Technician_Geographies__c
			FROM SVMXC__Service_Group_Members__c WHERE Id = :tech.Id];
		System.assertNotEquals(null, tech.SVMXC__Inventory_Location__c);
		System.assertNotEquals(null, tech.SMAX_PS_Technician_Geographies__c);

		// Validate that the loc.SVMXC__Service_Engineer__c is filled in
		loc = [SELECT Id, Name, SVMX_PS_External_ID__c, SVMXC__Service_Engineer__c 
			FROM SVMXC__Site__c WHERE Id = :loc.Id];
		System.assertNotEquals(null, loc.SVMXC__Service_Engineer__c);

		delete geoTech2;

		tech = [SELECT Id, Name, SMAX_PS_Plant__c, SMAX_PS_LocationCode__c, SVMXC__Inventory_Location__c, 
			SVMXC__Salesforce_User__c, SMAX_PS_Technician_Geographies__c
			FROM SVMXC__Service_Group_Members__c WHERE Id = :tech.Id];
		System.assertEquals(geoTech1.SMAX_PS_Location__c, tech.SMAX_PS_Technician_Geographies__c);
	}
	
    static testMethod void testGeoTechBatch()
    {
		SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
		team.Name = 'Test Team';
		insert team;

		SVMXC__Service_Group_Members__c tech = new SVMXC__Service_Group_Members__c();
		tech.SMAX_PS_Plant__c = 'TS12';
		tech.SMAX_PS_LocationCode__c = 'T001';
		tech.SVMXC__Service_Group__c = team.Id;
		insert tech;

		SMAX_PS_Geography_Technician__c geoTech1 = new SMAX_PS_Geography_Technician__c();
		geoTech1.SMAX_PS_Technician__c = tech.Id;
		geoTech1.SMAX_PS_Location__c = 'TST10';

		SMAX_PS_Geography_Technician__c geoTech2 = new SMAX_PS_Geography_Technician__c();
		geoTech2.SMAX_PS_Technician__c = tech.Id;
		geoTech2.SMAX_PS_Location__c = 'TST12';

		insert new List<SMAX_PS_Geography_Technician__c> { geoTech1, geoTech2 };

        Test.startTest();

        SMAX_PS_TechnicianGeoBatch b1 = new SMAX_PS_TechnicianGeoBatch();
        Database.executeBatch(b1);

        Test.stopTest();
    }

	// SVMXCFG-1136 additional logic for "Tech Geo 2" field
	static testMethod void testGeoTech2()
	{
		SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
		team.Name = 'Test Team';
		insert team;

		SVMXC__Service_Group_Members__c tech = new SVMXC__Service_Group_Members__c();
		tech.SMAX_PS_Plant__c = 'TS12';
		tech.SMAX_PS_LocationCode__c = 'T001';
		tech.SVMXC__Service_Group__c = team.Id;
		insert tech;

		List<SMAX_PS_Geography_Technician__c> geoTechs = new List<SMAX_PS_Geography_Technician__c>();
		for (Integer i = 10; i < 60; i++)
		{
			SMAX_PS_Geography_Technician__c geoTech = new SMAX_PS_Geography_Technician__c();
			geoTech.SMAX_PS_Technician__c = tech.Id;
			geoTech.SMAX_PS_Location__c = 'TESTLOC' + i;
			geoTechs.add(geoTech);
		}

		Test.startTest();

		insert geoTechs;

		SVMXC__Service_Group_Members__c result = [SELECT Id, Name,
				SMAX_PS_Technician_Geographies__c, SMAX_PS_Technician_Geographies_2__c
		FROM SVMXC__Service_Group_Members__c WHERE Id = :tech.Id];
		System.debug('RESULT = ' + result);

		System.assert(String.isNotBlank(result.SMAX_PS_Technician_Geographies__c));
		System.assert(String.isNotBlank(result.SMAX_PS_Technician_Geographies_2__c));

		Test.stopTest();
	}

	// ITSFDC-509 Lookup the Depot Queue Id
	static testMethod void testDepotQueue()
	{
		Group g1 = new Group(Name='TST FOODS TS12 Depot', DeveloperName='TST_FOODS_TS12_Depot', Type='Queue');
		insert g1;
		System.runAs(new User(Id=UserInfo.getUserId()))
		{
			QueueSobject q1 = new QueueSobject(QueueId = g1.Id, SobjectType = 'SVMXC__Service_Order__c');
			insert q1;
//			QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
//			insert testQueue;
		}

		Test.startTest();

		SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
		team.Name = 'Test Depot Team';
		insert team;

		SVMXC__Service_Group_Members__c tech = new SVMXC__Service_Group_Members__c();
		tech.SMAX_PS_Plant__c = 'TS12';
		tech.SMAX_PS_LocationCode__c = 'T001';
		tech.SVMXC__Service_Group__c = team.Id;
		tech.BD_Depot_Queue_Name__c = g1.DeveloperName;
		insert tech;

		Test.stopTest();

		SVMXC__Service_Group_Members__c techResult = [SELECT Id, Name, BD_Depot_Queue_Id__c
			FROM SVMXC__Service_Group_Members__c WHERE Id = :tech.Id];
		System.assertEquals(g1.Id, techResult.BD_Depot_Queue_Id__c);

	}
}