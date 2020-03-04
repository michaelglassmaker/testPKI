@isTest
private without sharing class SMAX_PS_AutoAssignment_UT {
	
	@isTest static void testIP_PreferredTech() {

		// SVMXCFG-647 - Cannot create new User due to managed package error
		//User techUser = SMAX_PS_TestDataFactory.createTestUser('testtech');
		User techUser = new User(Id = UserInfo.getUserId());
		SVMXC__Service_Group_Members__c tech = SMAX_PS_TestDataFactory.createTestTechnician('TestTeam01', techUser, 'Test Tech1', 'TS12', 'T001');

		String modelSeries = 'TST001';

		//SVMXC__Skill__c skill = SMAX_PS_TestDataFactory.createTestSkill(modelSeries);
		//SVMXC__Service_Group_Skills__c expertise = SMAX_PS_TestDataFactory.createTestExpertise(tech, skill);

		String locCode = 'TSTC01';
		//SMAX_PS_Geography__c geo = SMAX_PS_TestDataFactory.createTestGeography(locCode);
		//SMAX_PS_Geography_Technician__c gt1 = SMAX_PS_TestDataFactory.createTestGeoTech(geo, tech, 1);

		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001');
		Contact c = SMAX_PS_TestDataFactory.createTestContact('Testie', 'Testerson', acct, 'TEST000000101');
		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct, 'Test Location', 'TESTLOC001', locCode);
		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('TESTX0000234001', acct, loc, modelSeries);
		ip.SMAX_PS_PreferredTechnicianNumber__c = tech.SVMX_PS_External_ID__c;
		ip.SVMXC__Preferred_Technician__c = tech.Id;
		update ip;

		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createWO(ip, c);
		wo.SMAX_PS_Perform_Auto_Assignment__c = true;
		wo.SVMXC__Scheduled_Date__c = Date.today();
		// Simulate an update from SAP.. releasing the WO
		wo.SMAX_PS_SAP_SystemStatus__c = 'REL';
		wo.SMAX_PS_CreditHold__c = false;

		// This should cause Auto-Assignment to run
		update wo;

		SVMXC__Service_Order__c result = [SELECT Id, Name, SVMXC__Order_Status__c, SMAX_PS_AutoAssignmentNotes__c, SVMXC__Group_Member__c, OwnerId
			FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.debug('AUTO-ASSIGN RESULT WO: ' + result);
		System.assertNotEquals(null, result.SMAX_PS_AutoAssignmentNotes__c);
		System.assertEquals(tech.Id, result.SVMXC__Group_Member__c);

	}

	@isTest static void testIP_GeoSkills() {

		// SVMXCFG-647 - Cannot create new User due to managed package error
		//User techUser = SMAX_PS_TestDataFactory.createTestUser('testtech');
		User techUser = new User(Id = UserInfo.getUserId());
		SVMXC__Service_Group_Members__c tech = SMAX_PS_TestDataFactory.createTestTechnician('TestTeam01', techUser, 'Test Tech1', 'TS12', 'T001');

		String modelSeries = 'TST001';

		SVMXC__Skill__c skill = SMAX_PS_TestDataFactory.createTestSkill(modelSeries);
		SVMXC__Service_Group_Skills__c expertise = SMAX_PS_TestDataFactory.createTestExpertise(tech, skill);

		String locCode = 'TSTC01';
		SMAX_PS_Geography__c geo = SMAX_PS_TestDataFactory.createTestGeography(locCode);
		SMAX_PS_Geography_Technician__c gt1 = SMAX_PS_TestDataFactory.createTestGeoTech(geo, tech, 1);

		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001');
		Contact c = SMAX_PS_TestDataFactory.createTestContact('Testie', 'Testerson', acct, 'TEST000000101');
		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct, 'Test Location', 'TESTLOC001', locCode);
		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('TESTX0000234001', acct, loc, modelSeries);

		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createWO(ip, c);
		wo.SMAX_PS_Perform_Auto_Assignment__c = true;
		wo.SVMXC__Scheduled_Date__c = Date.today().addDays(30);
		// Simulate an update from SAP.. releasing the WO
		wo.SMAX_PS_SAP_SystemStatus__c = 'REL';
		wo.SMAX_PS_CreditHold__c = false;

		// This should cause Auto-Assignment to run
		update wo;

		SVMXC__Service_Order__c result = [SELECT Id, Name, SVMXC__Order_Status__c, SMAX_PS_AutoAssignmentNotes__c, SVMXC__Group_Member__c, OwnerId
			FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.debug('AUTO-ASSIGN RESULT WO: ' + result);
		System.assertNotEquals(null, result.SMAX_PS_AutoAssignmentNotes__c);
		System.assertEquals(tech.Id, result.SVMXC__Group_Member__c);

	}
	
	@isTest static void testIP_GeoOnly() {

		// SVMXCFG-647 - Cannot create new User due to managed package error
		//User techUser = SMAX_PS_TestDataFactory.createTestUser('testtech');
		User techUser = new User(Id = UserInfo.getUserId());
		SVMXC__Service_Group_Members__c tech = SMAX_PS_TestDataFactory.createTestTechnician('TestTeam01', techUser, 'Test Tech1', 'TS12', 'T001');

		// No SKILL...
		//String modelSeries = 'TST001';
		//SVMXC__Skill__c skill = SMAX_PS_TestDataFactory.createTestSkill(modelSeries);
		//SVMXC__Service_Group_Skills__c expertise = SMAX_PS_TestDataFactory.createTestExpertise(tech, skill);

		String locCode = 'TSTC01';
		SMAX_PS_Geography__c geo = SMAX_PS_TestDataFactory.createTestGeography(locCode);
		SMAX_PS_Geography_Technician__c gt1 = SMAX_PS_TestDataFactory.createTestGeoTech(geo, tech, 1);

		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001');
		Contact c = SMAX_PS_TestDataFactory.createTestContact('Testie', 'Testerson', acct, 'TEST000000101');
		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct, 'Test Location', 'TESTLOC001', locCode);
		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('TESTX0000234001', acct, loc, null); //modelSeries);

		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createWO(ip, c);
		wo.SMAX_PS_Perform_Auto_Assignment__c = true;
		wo.SVMXC__Scheduled_Date__c = Date.today().addDays(30);
		// Simulate an update from SAP.. releasing the WO
		wo.SMAX_PS_SAP_SystemStatus__c = 'REL';
		wo.SMAX_PS_CreditHold__c = false;

		// This should cause Auto-Assignment to run
		update wo;

		SVMXC__Service_Order__c result = [SELECT Id, Name, SVMXC__Order_Status__c, SMAX_PS_AutoAssignmentNotes__c, SVMXC__Group_Member__c, OwnerId
			FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.debug('AUTO-ASSIGN RESULT WO: ' + result);
		System.assertNotEquals(null, result.SMAX_PS_AutoAssignmentNotes__c);

		// SVMXCFG-693 Do not assign by Geo Only
		//System.assertEquals(tech.Id, result.SVMXC__Group_Member__c);
		System.assertEquals(null, result.SVMXC__Group_Member__c);

	}

	@isTest static void testInstall_GeoSkills() {

		// SVMXCFG-647 - Cannot create new User due to managed package error
		//User techUser = SMAX_PS_TestDataFactory.createTestUser('testtech');
		User techUser = new User(Id = UserInfo.getUserId());
		SVMXC__Service_Group_Members__c tech = SMAX_PS_TestDataFactory.createTestTechnician('TestTeam01', techUser, 'Test Tech1', 'TS12', 'T001');

		String modelSeries = 'TST001';

		SVMXC__Skill__c skill = SMAX_PS_TestDataFactory.createTestSkill(modelSeries);
		SVMXC__Service_Group_Skills__c expertise = SMAX_PS_TestDataFactory.createTestExpertise(tech, skill);

		String locCode = 'TSTC01';
		SMAX_PS_Geography__c geo = SMAX_PS_TestDataFactory.createTestGeography(locCode);
		SMAX_PS_Geography_Technician__c gt1 = SMAX_PS_TestDataFactory.createTestGeoTech(geo, tech, 1);

		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001');
		Contact c = SMAX_PS_TestDataFactory.createTestContact('Testie', 'Testerson', acct, 'TEST000000101');
		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct, 'Test Location', 'TESTLOC001', locCode);
		//SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('TESTX0000234001', acct, loc, modelSeries);

		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createInstallWO(acct, loc, null, c);
		wo.SMAX_PS_Perform_Auto_Assignment__c = true;
		wo.SVMXC__Scheduled_Date__c = Date.today().addDays(30);
		wo.SMAX_PS_ProductSeries__c = modelSeries;
		// Simulate an update from SAP.. releasing the WO
		wo.SMAX_PS_SAP_SystemStatus__c = 'REL';
		wo.SMAX_PS_CreditHold__c = false;

		// This should cause Auto-Assignment to run
		update wo;

		SVMXC__Service_Order__c result = [SELECT Id, Name, SVMXC__Order_Status__c, SMAX_PS_AutoAssignmentNotes__c, SVMXC__Group_Member__c, OwnerId
			FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.debug('AUTO-ASSIGN RESULT WO: ' + result);
		System.assertNotEquals(null, result.SMAX_PS_AutoAssignmentNotes__c);
		System.assertEquals(tech.Id, result.SVMXC__Group_Member__c);

	}
	
	@isTest static void testInstall_GeoOnly() {

		// SVMXCFG-647 - Cannot create new User due to managed package error
		//User techUser = SMAX_PS_TestDataFactory.createTestUser('testtech');
		User techUser = new User(Id = UserInfo.getUserId());
		SVMXC__Service_Group_Members__c tech = SMAX_PS_TestDataFactory.createTestTechnician('TestTeam01', techUser, 'Test Tech1', 'TS12', 'T001');

		//String modelSeries = 'TST001';

		//SVMXC__Skill__c skill = SMAX_PS_TestDataFactory.createTestSkill(modelSeries);
		//SVMXC__Service_Group_Skills__c expertise = SMAX_PS_TestDataFactory.createTestExpertise(tech, skill);

		String locCode = 'TSTC01';
		SMAX_PS_Geography__c geo = SMAX_PS_TestDataFactory.createTestGeography(locCode);
		SMAX_PS_Geography_Technician__c gt1 = SMAX_PS_TestDataFactory.createTestGeoTech(geo, tech, 1);

		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001');
		Contact c = SMAX_PS_TestDataFactory.createTestContact('Testie', 'Testerson', acct, 'TEST000000101');
		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct, 'Test Location', 'TESTLOC001', locCode);
		//SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('TESTX0000234001', acct, loc, modelSeries);

		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createInstallWO(acct, loc, null, c);
		wo.SMAX_PS_Perform_Auto_Assignment__c = true;
		wo.SVMXC__Scheduled_Date__c = Date.today().addDays(30);
		//wo.SMAX_PS_ProductSeries__c = modelSeries;
		// Simulate an update from SAP.. releasing the WO
		wo.SMAX_PS_SAP_SystemStatus__c = 'REL';
		wo.SMAX_PS_CreditHold__c = false;

		// This should cause Auto-Assignment to run
		update wo;

		SVMXC__Service_Order__c result = [SELECT Id, Name, SVMXC__Order_Status__c, SMAX_PS_AutoAssignmentNotes__c, SVMXC__Group_Member__c, OwnerId
			FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.debug('AUTO-ASSIGN RESULT WO: ' + result);
		System.assertNotEquals(null, result.SMAX_PS_AutoAssignmentNotes__c);
		
		// SVMXCFG-693 Do not assign by Geo Only
		//System.assertEquals(tech.Id, result.SVMXC__Group_Member__c);
		System.assertEquals(null, result.SVMXC__Group_Member__c);

	}
	
	@isTest static void testScheduling() {

		// SVMXCFG-647 - Cannot create new User due to managed package error
		//User techUser = SMAX_PS_TestDataFactory.createTestUser('testtech');
		User techUser = new User(Id = UserInfo.getUserId());
		SVMXC__Service_Group_Members__c tech = SMAX_PS_TestDataFactory.createTestTechnician('TestTeam01', techUser, 'Test Tech1', 'TS12', 'T001');

		String modelSeries = 'TST001';
		String locCode = 'TSTC01';

		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001');
		Contact c = SMAX_PS_TestDataFactory.createTestContact('Testie', 'Testerson', acct, 'TEST000000101');
		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct, 'Test Location', 'TESTLOC001', locCode);
		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('TESTX0000234001', acct, loc, modelSeries);
		ip.SMAX_PS_PreferredTechnicianNumber__c = tech.SVMX_PS_External_ID__c;
		ip.SVMXC__Preferred_Technician__c = tech.Id;
		update ip;

		SVMXC__Installed_Product__c ipResult = [SELECT Id, SVMXC__Preferred_Technician__c FROM SVMXC__Installed_Product__c WHERE Id = :ip.Id];
		System.assertEquals(tech.Id, ipResult.SVMXC__Preferred_Technician__c);

		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createWO(ip, c);
		wo.SMAX_PS_Perform_Auto_Assignment__c = true;
		wo.SVMXC__Scheduled_Date__c = Date.today();
		// Simulate an update from SAP.. releasing the WO
		wo.SMAX_PS_SAP_SystemStatus__c = 'REL';
		wo.SMAX_PS_CreditHold__c = false;

		// This should cause Auto-Assignment to run
		update wo;

		Test.startTest();
		SMAX_PS_AutoAssignment.clearSynchronizedList();

		SVMXC__Service_Order__c result = [SELECT Id, Name, SVMXC__Order_Status__c, SVMXC__Scheduled_Date_Time__c, SVMXC__Group_Member__c, OwnerId
			FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.debug('AUTO-ASSIGN RESULT WO: ' + result);
		System.assertEquals(tech.Id, result.SVMXC__Group_Member__c);
		System.assertNotEquals(null, result.SVMXC__Scheduled_Date_Time__c);

		Event evt = [SELECT Id, StartDateTime, WhatId FROM Event WHERE WhatId = :wo.Id];
		System.assertNotEquals(null, evt);
		System.assertEquals(result.SVMXC__Scheduled_Date_Time__c, evt.StartDateTime);

		result.SVMXC__Scheduled_Date_Time__c = result.SVMXC__Scheduled_Date_Time__c.addDays(1).addHours(4);
		update result;

		Test.stopTest();

		Event evt2 = [SELECT Id, StartDateTime, WhatId FROM Event WHERE WhatId = :wo.Id];
		System.assertNotEquals(null, evt2);
		System.assertEquals(result.SVMXC__Scheduled_Date_Time__c, evt2.StartDateTime);
	}

	@isTest static void testSapWorkCenter() {

		// SVMXCFG-647 - Cannot create new User due to managed package error
		//User techUser = SMAX_PS_TestDataFactory.createTestUser('testtech');
		User techUser = new User(Id = UserInfo.getUserId());
		String plant = 'TS12';
		String workCenter = 'TS71234';
		SVMXC__Service_Group_Members__c tech = SMAX_PS_TestDataFactory.createTestTechnician('TestTeam01', techUser, 'Test Tech1', plant, 'T001', workCenter);

		String modelSeries = 'TST001';
		String locCode = 'TSTC01';
		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001');
		Contact c = SMAX_PS_TestDataFactory.createTestContact('Testie', 'Testerson', acct, 'TEST000000101');
		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct, 'Test Location', 'TESTLOC001', locCode);
		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('TESTX0000234001', acct, loc, modelSeries);
		//ip.SVMXC__Preferred_Technician__c = tech.Id;
		//update ip;

		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createWO(ip, c);
		wo.SMAX_PS_Perform_Auto_Assignment__c = true;
		wo.SVMXC__Scheduled_Date__c = Date.today();
		// Simulate an update from SAP.. releasing the WO
		wo.SMAX_PS_SAP_SystemStatus__c = 'REL';
		wo.SMAX_PS_CreditHold__c = false;
		wo.SMAX_PS_SAP_Work_Center__c = workCenter;
		wo.SMAX_PS_SAP_Maintenance_Plant__c = plant;

		// This should cause Auto-Assignment to run
		update wo;

		SVMXC__Service_Order__c result = [SELECT Id, Name, SVMXC__Order_Status__c, SMAX_PS_AutoAssignmentNotes__c, SVMXC__Group_Member__c, OwnerId
			FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.debug('AUTO-ASSIGN RESULT WO: ' + result);
		System.assertNotEquals(null, result.SMAX_PS_AutoAssignmentNotes__c);
		System.assert(result.SMAX_PS_AutoAssignmentNotes__c.contains('SAP Work Center'));
		System.assertEquals(tech.Id, result.SVMXC__Group_Member__c);

	}

	@isTest static void testEnterprise_GeoSkills() {

		// SVMXCFG-693 - "Is Enterprise" on Team must match WO
		//User techUser = SMAX_PS_TestDataFactory.createTestUser('testtech');
		User techUser = new User(Id = UserInfo.getUserId());
		SVMXC__Service_Group_Members__c tech1 = SMAX_PS_TestDataFactory.createTestTechnician('TestTeam01', techUser, 'Test Tech1', 'TS12', 'T001');
		SVMXC__Service_Group_Members__c tech2 = SMAX_PS_TestDataFactory.createTestTechnician('EnterpriseTeam02', techUser, 'Enterprise Tech2', 'TS12', 'T002');

        SVMXC__Service_Group__c team2 = new SVMXC__Service_Group__c(Id = tech2.SVMXC__Service_Group__c);
        team2.SMAX_PS_Is_Enterprise__c = true;
        update team2;

		String modelSeries = 'TST001';

		SVMXC__Skill__c skill = SMAX_PS_TestDataFactory.createTestSkill(modelSeries);
		SVMXC__Service_Group_Skills__c expertise1 = SMAX_PS_TestDataFactory.createTestExpertise(tech1, skill);
		SVMXC__Service_Group_Skills__c expertise2 = SMAX_PS_TestDataFactory.createTestExpertise(tech2, skill);

		String locCode = 'TSTC01';
		SMAX_PS_Geography__c geo = SMAX_PS_TestDataFactory.createTestGeography(locCode);
		SMAX_PS_Geography_Technician__c gt1 = SMAX_PS_TestDataFactory.createTestGeoTech(geo, tech1, 1);
		SMAX_PS_Geography_Technician__c gt2 = SMAX_PS_TestDataFactory.createTestGeoTech(geo, tech2, 1);

		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001');
		Contact c = SMAX_PS_TestDataFactory.createTestContact('Testie', 'Testerson', acct, 'TEST000000101');
		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct, 'Test Location', 'TESTLOC001', locCode);
		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('TESTX0000234001', acct, loc, modelSeries);

		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createWO(ip, c);
		wo.SMAX_PS_Perform_Auto_Assignment__c = true;
		wo.SVMXC__Scheduled_Date__c = Date.today().addDays(30);
		// Simulate an update from SAP.. releasing the WO
		wo.SMAX_PS_SAP_SystemStatus__c = 'REL';
		wo.SMAX_PS_CreditHold__c = false;
		wo.SMAX_PS_Is_Enterprise__c = true;

		// This should cause Auto-Assignment to run
		update wo;

		SVMXC__Service_Order__c result = [SELECT Id, Name, SVMXC__Order_Status__c, SMAX_PS_AutoAssignmentNotes__c, SVMXC__Group_Member__c, OwnerId
			FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.debug('AUTO-ASSIGN RESULT WO: ' + result);
		System.assertNotEquals(null, result.SMAX_PS_AutoAssignmentNotes__c);
		System.assertEquals(tech2.Id, result.SVMXC__Group_Member__c);

	}

	@isTest static void testFinishAssignment() {

		User techUser = SMAX_PS_TestDataFactory.createTestUser('testtech');
		SVMXC__Service_Group_Members__c tech1 = SMAX_PS_TestDataFactory.createTestTechnician('TestTeam01', techUser, 'Test Tech1', 'TS12', 'T001');
		String modelSeries = 'TST001';

		SVMXC__Skill__c skill = SMAX_PS_TestDataFactory.createTestSkill(modelSeries);
		SVMXC__Service_Group_Skills__c expertise1 = SMAX_PS_TestDataFactory.createTestExpertise(tech1, skill);

		String locCode = 'TSTC01';
		SMAX_PS_Geography__c geo = SMAX_PS_TestDataFactory.createTestGeography(locCode);
		SMAX_PS_Geography_Technician__c gt1 = SMAX_PS_TestDataFactory.createTestGeoTech(geo, tech1, 1);

		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001');
		Contact c = SMAX_PS_TestDataFactory.createTestContact('Testie', 'Testerson', acct, 'TEST000000101');
		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct, 'Test Location', 'TESTLOC001', locCode);
		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('TESTX0000234001', acct, loc, modelSeries);

		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createPendingIpWO(ip, c);

		// This simulates the assign SFM... should cause finishAssignment() to run
		wo.SVMXC__Group_Member__c = tech1.Id;
		update wo;

		SVMXC__Service_Order__c result = [SELECT Id, Name, SVMXC__Group_Member__c, OwnerId
			FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.debug('AUTO-ASSIGN RESULT WO: ' + result);
		System.assertEquals(tech1.Id, result.SVMXC__Group_Member__c);
		System.assertEquals(techUser.Id, result.OwnerId);

	}

	// SVMXCFG-723 - 09/05/18 - Tests SMAX_PS_AutoAssignment.syncEventFields 
	@isTest static void testSyncEventFields()
	{
		User techUser = SMAX_PS_TestDataFactory.createTestUser('testtech');
		SVMXC__Service_Group_Members__c tech1 = SMAX_PS_TestDataFactory.createTestTechnician('TestTeam01', techUser, 'Test Tech1', 'TS12', 'T001');
		String modelSeries = 'TST001';

		SVMXC__Skill__c skill = SMAX_PS_TestDataFactory.createTestSkill(modelSeries);
		SVMXC__Service_Group_Skills__c expertise1 = SMAX_PS_TestDataFactory.createTestExpertise(tech1, skill);

		String locCode = 'TSTC01';
		SMAX_PS_Geography__c geo = SMAX_PS_TestDataFactory.createTestGeography(locCode);
		SMAX_PS_Geography_Technician__c gt1 = SMAX_PS_TestDataFactory.createTestGeoTech(geo, tech1, 1);

		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001');
		Contact c = SMAX_PS_TestDataFactory.createTestContact('Testie', 'Testerson', acct, 'TEST000000101');
		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct, 'Test Location', 'TESTLOC001', locCode);
		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('TESTX0000234001', acct, loc, modelSeries);

		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createPendingIpWO(ip, c);
		wo.SMAX_PS_ContactName__c = 'Testie Testerson';
		update wo;

		Event e = new Event();
		e.whatId = wo.id;
		e.DurationInMinutes = 5;
		e.ActivityDateTime = datetime.now()+1; 
		insert e;

		Event eResult = [SELECT Id, SMAX_PS_Company__c, SMAX_PS_Contact_Name__c, SMAX_PS_Contact_Phone__c,
								SMAX_PS_Order_Type__c, SMAX_PS_Instrument__c, Description
							FROM Event 
							WHERE Id = :e.Id];

		System.debug('Events order type is ' + eResult.SMAX_PS_Order_Type__c);
		SVMXC__Installed_Product__c ipResult = [SELECT Id, Name FROM SVMXC__Installed_Product__c WHERE Id = :ip.Id];

		System.assertEquals(acct.Name, eResult.SMAX_PS_Company__c);
		System.assertEquals(wo.SMAX_PS_ContactName__c, eResult.SMAX_PS_Contact_Name__c);
		System.assertEquals(wo.SVMX_PS_Contact_Phone__c, eResult.SMAX_PS_Contact_Phone__c);
		System.assertEquals(wo.SVMXC__Order_Type__c, eResult.SMAX_PS_Order_Type__c);
		System.assertEquals(ipResult.Name, eResult.SMAX_PS_Instrument__c);

		System.debug('Event Description is ' + eResult.Description);
	}

	@isTest static void testServiceEstimateAssign() {

		User techUser = SMAX_PS_TestDataFactory.createTestUser('testtech');
		SVMXC__Service_Group_Members__c tech1 = SMAX_PS_TestDataFactory.createTestTechnician('TestTeam01', techUser, 'Test Tech1', 'TS12', 'T001');
		String modelSeries = 'TST001';

		String locCode = 'TSTC01';
		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001');
		Contact c = SMAX_PS_TestDataFactory.createTestContact('Testie', 'Testerson', acct, 'TEST000000101');
		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct, 'Test Location', 'TESTLOC001', locCode);
		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('TESTX0000234001', acct, loc, modelSeries);

		SVMXC__Site__c techLoc = SMAX_PS_TestDataFactory.createTestLocation(acct, 'Tech Location', 'TECHLOC001', 'TECH01');
		techLoc.SMAX_PS_SalesOrg__c = 'TT10';
		update techLoc;

		tech1.SVMXC__Inventory_Location__c = techLoc.Id;
		update tech1;

		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createServiceEstimateWO(ip, c);
		wo.OwnerId = techUser.Id;
		update wo;
		
		SVMXC__Service_Order__c result = [SELECT Id, Name, SVMXC__Group_Member__c, SVMXC__Order_Status__c, OwnerId, SMAX_PS_TechnicianSalesOrg__c
			FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.debug('AUTO-ASSIGN RESULT SERVICE_REQUEST: ' + result);
		System.assertEquals(tech1.Id, result.SVMXC__Group_Member__c);
		System.assertEquals(techUser.Id, result.OwnerId);
		// SVMXCFG-1109 Verify Tech Sales Org gets populated
		System.assertEquals(techLoc.SMAX_PS_SalesOrg__c, result.SMAX_PS_TechnicianSalesOrg__c);

		List<Event> events = [SELECT Id, WhatId FROM Event WHERE WhatId = :result.Id];
		System.assertEquals(1, events.size());
		Event theEvt = events.get(0);

		// Test the Conversion to a real WO...
		SMAX_PS_AutoAssignment.clearSynchronizedList();
		RecordType fsRecType = SMAX_PS_Utility.getRecordType('SVMXC__Service_Order__c', 'Field_Service');
		wo.RecordTypeId = fsRecType.Id;
		wo.SMAX_PS_Converted_from_Estimate__c = true;
		update wo;

		Event updatedEvent = [SELECT Id, StartDateTime FROM Event WHERE Id = :theEvt.Id];
		System.assertEquals(Date.today().addDays(1), updatedEvent.StartDateTime.date());
	}

	@isTest static void testDepotAssign() {

		User techUser = SMAX_PS_TestDataFactory.createTestUser('testtech');
		SVMXC__Service_Group_Members__c tech1 = SMAX_PS_TestDataFactory.createTestTechnician('TestTeam01', techUser, 'Test Tech1', 'TS12', 'T001');
		String modelSeries = 'TST001';

		String locCode = 'TSTC01';
		Account acct = SMAX_PS_TestDataFactory.createTestAccount('PkiTest', 'TESTX000000001');
		Contact c = SMAX_PS_TestDataFactory.createTestContact('Testie', 'Testerson', acct, 'TEST000000101');
		SVMXC__Site__c loc = SMAX_PS_TestDataFactory.createTestLocation(acct, 'Test Location', 'TESTLOC001', locCode);
		SVMXC__Installed_Product__c ip = SMAX_PS_TestDataFactory.createIP('TESTX0000234001', acct, loc, modelSeries);

		SVMXC__Site__c techLoc = SMAX_PS_TestDataFactory.createTestLocation(acct, 'Tech Location', 'TECHLOC001', 'TECH01');
		techLoc.SMAX_PS_SalesOrg__c = 'TT10';
		update techLoc;

		tech1.SVMXC__Inventory_Location__c = techLoc.Id;
		update tech1;

		RecordType depotRT = SMAX_PS_Utility.getRecordType('SVMXC__Service_Order__c', 'Depot_Repair');

		SVMXC__Service_Order__c wo = SMAX_PS_TestDataFactory.createWO(ip, c);
		wo.RecordTypeId = depotRT.Id;
		wo.SMAX_PS_SAP_SystemStatus__c = 'REL';
		wo.SMAX_PS_CreditHold__c = false;
		update wo;

		Test.startTest();

		wo.OwnerId = techUser.Id;
		update wo;

		SVMXC__Service_Order__c result = [SELECT Id, Name, SVMXC__Group_Member__c, SVMXC__Order_Status__c, OwnerId, SMAX_PS_TechnicianSalesOrg__c
		FROM SVMXC__Service_Order__c WHERE Id = :wo.Id];
		System.debug('AUTO-ASSIGN RESULT SERVICE_REQUEST: ' + result);
		System.assertEquals(tech1.Id, result.SVMXC__Group_Member__c);
		System.assertEquals(techUser.Id, result.OwnerId);
		// SVMXCFG-1109 Verify Tech Sales Org gets populated
		System.assertEquals(techLoc.SMAX_PS_SalesOrg__c, result.SMAX_PS_TechnicianSalesOrg__c);

		List<Event> events = [SELECT Id, WhatId FROM Event WHERE WhatId = :result.Id];
		System.assertEquals(1, events.size());

		Test.stopTest();
	}
}