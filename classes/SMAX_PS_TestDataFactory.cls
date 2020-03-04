@isTest(SeeAllData=true)

public class SMAX_PS_TestDataFactory {
    private SMAX_PS_TestDataFactory() {
    }

    public static User createTestUser(String alias)
    {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'SVMX PS - Field Engineer']; 
        User user = new User(alias = alias, email = alias+'Mail@yahoo.com',
            emailEncodingKey = 'UTF-8', languageLocaleKey = 'en_US', firstname = alias, lastName = 'Testofferson',
            localeSidKey = 'en_US', timeZoneSidKey = 'America/Los_Angeles', profileId = p.Id,
            /*PKI_GBL_Job_Family__c = 'Service',*/ username = alias+'Mail@yahoo.com', communityNickname = alias+'Boy');
        insert user;

        return user;
    }

    public static Account createTestAccount(String name, String extId)
    {
        return createTestAccount(name, extId, 'US');
    }

    public static Account createTestAccount(String name, String extId, String countryCode)
    {
        RecordType customerRecType = SMAX_PS_Utility.getRecordType('Account', 'Customer');
        Account acct = new Account();
        acct.RecordTypeId = customerRecType.Id;
        acct.Name = name;
        acct.PKI_SAP_Customer_Number__c = extId;
        acct.PKI_SAP_Country_Code__c = countryCode;
        // 2018-03-16 MAPLES - Added the new fields for Payer address
        acct.ShippingStreet = '123 TEST Street';
        acct.ShippingCity = 'No-where';
        acct.ShippingState = 'FR';
        acct.ShippingPostalCode = '12345';
        acct.ShippingCountry = countryCode;
        acct.CurrencyIsoCode = 'USD';
        // 2018-03-16 MAPLES - END of Updates
        acct.BillingCountry = countryCode;
        insert acct;

        return acct;
    }

    public static Contact createTestContact(String first, String last, Account acct, String contactID)
    {
        Contact c = new Contact();
        c.FirstName = first;
        c.LastName = last;
        c.PKI_SAP_Contact_ID__c = contactID;
        c.AccountId = acct.Id;
        c.MailingCountry = 'US';
        insert c;

        return c;
    }

    public static SMAX_PS_Geography__c createTestGeography(String locCode)
    {
        SMAX_PS_Geography__c geo = new SMAX_PS_Geography__c();
        geo.Name = locCode;
        geo.SMAX_PS_LocationCode__c = locCode;
        insert geo;

        return geo;
    }

    public static SVMXC__Service_Group_Members__c createTestTechnician(String teamName, User user, String techName, String plant, String locCode)
    {
        return createTestTechnician(teamName, user, techName, plant, locCode, locCode);
    }

    public static SVMXC__Service_Group_Members__c createTestTechnician(String teamName, User user, String techName, String plant, String locCode, String workCenter)
    {
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = teamName;
        insert team;

        SVMXC__Service_Group_Members__c tech = new SVMXC__Service_Group_Members__c();
        tech.SMAX_PS_Plant__c = plant;
        tech.SMAX_PS_LocationCode__c = locCode;
        tech.SMAX_PS_Work_Center__c = workCenter;
        tech.SVMX_PS_External_ID__c = plant + workCenter;
        tech.SVMXC__Service_Group__c = team.Id;
        tech.SVMXC__Salesforce_User__c = (user == null) ? null : user.Id;
        tech.SVMXC__Active__c = true;
        tech.SVMXC__Enable_Scheduling__c = true;
        insert tech;

        return tech;
    }

    public static SVMXC__Skill__c createTestSkill(String skillName)
    {
        SVMXC__Skill__c skill = new SVMXC__Skill__c();
        skill.Name = skillName;
        skill.SVMX_PS_Skill_External_ID__c = skillName;
        insert skill;
        return skill;
    }

    public static SVMXC__Service_Group_Skills__c createTestExpertise(SVMXC__Service_Group_Members__c tech, SVMXC__Skill__c skill)
    {
        SVMXC__Service_Group_Skills__c expertise = new SVMXC__Service_Group_Skills__c();
        expertise.SVMXC__Service_Group__c = tech.SVMXC__Service_Group__c;
        expertise.SVMXC__Group_Member__c = tech.Id;
        expertise.SVMXC__Skill__c = skill.Id;
        insert expertise;
        return expertise;
    }

    public static SMAX_PS_Geography_Technician__c createTestGeoTech(SMAX_PS_Geography__c geo, SVMXC__Service_Group_Members__c tech, Integer rank)
    {
        SMAX_PS_Geography_Technician__c gt1 = new SMAX_PS_Geography_Technician__c();
        gt1.SMAX_PS_Geography__c = geo.Id;
        gt1.SMAX_PS_Technician__c = tech.Id;
        gt1.SMAX_PS_Location__c = geo.SMAX_PS_LocationCode__c;
        gt1.SMAX_PS_Rank__c = rank;
        insert gt1;
        return gt1;     
    }

    public static SVMXC__Site__c createTestLocation(Account acct, String name, String extId, String locCode)
    {
        SVMXC__Site__c loc = new SVMXC__Site__c();
        loc.Name = name;
        loc.SVMXC__Account__c = acct.Id;
        loc.SVMX_PS_External_ID__c = extId;
        loc.SMAX_PS_LocationCode__c = locCode;
        loc.SMAX_PS_ShipTo__c = acct.Id;
        loc.SMAX_PS_Payer__c = acct.Id;
        loc.SMAX_PS_BillTo__c = acct.Id;
        insert loc;

        return loc;
    }

    public static Map<String, Account> createTestPartnerAccounts(Account acct)
    {
        Map<String, Account> result = new Map<String, Account>();
        Set<String> functionNames = new Set<String> { 'BillTo', 'Payer', 'ShipTo', 'LocalLangBillTo', 'LocalLangShipTo' };
        for (String function : functionNames)
        {
            Account site = new Account();
            site.Name = acct.Name + ' ' + function;
            String abbr = function.startsWith('LocalLang') ? function.replace('LocalLang', 'L').left(2) : function.left(1);
            site.PKI_SAP_Customer_Number__c = acct.PKI_SAP_Customer_Number__c.replace('X', abbr);
            //site.PKI_SAP_Function__c = function;
            site.ShippingStreet = acct.ShippingStreet;
            site.ShippingCity = acct.ShippingCity;
            site.ShippingState = acct.ShippingState;
            site.ShippingPostalCode = acct.ShippingPostalCode;
            site.ShippingCountry = acct.ShippingCountry;
            site.CurrencyIsoCode = acct.CurrencyIsoCode;
            // TODO: Fill in RecordType, Type
            result.put(function, site);
        }
        insert result.values();

        List<Account_Function__c> functions = new List<Account_Function__c>();
        for (String functionName : result.keySet())
        {
            Account site = result.get(functionName);

            Account_Function__c function = new Account_Function__c();
            function.Key__c = site.PKI_SAP_Customer_Number__c + '_' + functionName;
            function.Source_Account__c = acct.Id;
            function.PKI_SAP_Source_Account_Number__c = acct.PKI_SAP_Customer_Number__c;
            function.Target_Account__c = site.Id;
            function.PKI_SAP_Target_Account_Number__c = site.PKI_SAP_Customer_Number__c;
            if (functionName == 'BillTo')
            {
                function.PKI_SAP_Partner_Type__c = 'RE';
                function.PKI_SAP_Partner_Type_Name__c = 'Bill To';
            }
            if (functionName == 'Payer')
            {
                function.PKI_SAP_Partner_Type__c = 'RG';
                function.PKI_SAP_Partner_Type_Name__c = 'Payer';
            }
            if (functionName == 'ShipTo')
            {
                function.PKI_SAP_Partner_Type__c = 'WE';
                function.PKI_SAP_Partner_Type_Name__c = 'Ship To';
            }
            if (functionName == 'LocalLangBillTo')
            {
                function.PKI_SAP_Partner_Type__c = 'YA';
                function.PKI_SAP_Partner_Type_Name__c = 'Local Language Bill To';
            }
            if (functionName == 'LocalLangShipTo')
            {
                function.PKI_SAP_Partner_Type__c = 'YB';
                function.PKI_SAP_Partner_Type_Name__c = 'Local Language Ship To';
            }
            functions.add(function);
        }
        insert functions;

        return result;
    }

    public static SVMXC__Service_Order__c createWO(SVMXC__Installed_Product__c ip, Contact c){
        RecordType fsRecType = SMAX_PS_Utility.getRecordType('SVMXC__Service_Order__c', 'Field_Service');
        Date startDate = System.today();
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.RecordTypeId = fsRecType.Id;
        wo.SVMXC__Component__c = ip.id;
        wo.SVMXC__Perform_Auto_Entitlement__c = TRUE;
        wo.SVMXC__Billing_Type__c = 'Billable';
        wo.SVMXC__Order_Type__c = 'Repair';
        wo.SVMXC__Company__c = ip.SVMXC__Company__c;
        wo.SVMXC__Site__c = ip.SVMXC__Site__c;
        wo.SVMXC__Scheduled_Date__c = startDate.addMonths(1);
        wo.SVMXC__Contact__c = c.Id;
        insert wo;
        return wo;
    }

    public static SVMXC__Service_Order__c createPendingIpWO(SVMXC__Installed_Product__c ip, Contact c){
        RecordType piRecType = SMAX_PS_Utility.getRecordType('SVMXC__Service_Order__c', 'Enterprise_Pending_IP');
        Date startDate = System.today();
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.RecordTypeId = piRecType.Id;
        wo.SVMXC__Component__c = ip.id;
        wo.SVMXC__Perform_Auto_Entitlement__c = FALSE;
        wo.SVMXC__Billing_Type__c = 'Billable';
        wo.SVMXC__Order_Type__c = 'Repair';
        wo.SVMXC__Company__c = ip.SVMXC__Company__c;
        wo.SVMXC__Site__c = ip.SVMXC__Site__c;
        wo.SVMXC__Scheduled_Date__c = startDate.addMonths(1);
        wo.SVMXC__Contact__c = c.Id;
        wo.SMAX_PS_Perform_Auto_Assignment__c = FALSE;
        insert wo;
        return wo;
    }

    //Create a Work Order for Auto Entitlement Testing
    public static SVMXC__Service_Order__c createContractWO(SVMXC__Installed_Product__c ip, Contact c){
        Date startDate = System.today();
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__Component__c = ip.id;
        wo.SVMXC__Perform_Auto_Entitlement__c = TRUE;
        wo.SVMXC__Billing_Type__c = 'Contract';
        wo.SVMXC__Order_Type__c = 'Repair';
        wo.SVMXC__Company__c = ip.SVMXC__Company__c;
        wo.SVMXC__Site__c = ip.SVMXC__Site__c;
        wo.SVMXC__Scheduled_Date__c = startDate.addMonths(1);
        wo.SVMXC__Contact__c = c.Id;
        insert wo;
        return wo;
    }

    public static SVMXC__Service_Order__c createInstallWO(Account acct, SVMXC__Site__c loc, Product2 prod, Contact c){
        Date startDate = System.today();
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__Perform_Auto_Entitlement__c = TRUE;
        wo.SVMXC__Billing_Type__c = 'Installation';
        wo.SVMXC__Order_Type__c = 'Installation';
        wo.SVMXC__Scheduled_Date__c = startDate.addMonths(1);
        wo.SVMXC__Company__c = acct.Id;
        wo.SVMXC__Site__c = loc.Id;
        wo.SVMXC__Product__c = (prod == null) ? null : prod.Id;
        wo.SVMXC__Contact__c = c.Id;
        insert wo;
        return wo;
    }

    public static SVMXC__Service_Order__c createServiceEstimateWO(SVMXC__Installed_Product__c ip, Contact c){
        RecordType recType = SMAX_PS_Utility.getRecordType('SVMXC__Service_Order__c', 'Service_Request');
        Date startDate = System.today();
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.RecordTypeId = recType.Id;
        wo.SVMXC__Component__c = ip.id;
        wo.SVMXC__Perform_Auto_Entitlement__c = FALSE;
        wo.SVMXC__Billing_Type__c = 'Billable';
        wo.SVMXC__Order_Type__c = 'Repair';
        wo.SVMXC__Company__c = ip.SVMXC__Company__c;
        wo.SVMXC__Site__c = ip.SVMXC__Site__c;
        wo.SVMXC__Scheduled_Date__c = startDate.addMonths(1);
        wo.SVMXC__Contact__c = c.Id;
        wo.SMAX_PS_Perform_Auto_Assignment__c = FALSE;
        insert wo;
        return wo;
    }

    public static SVMXC__Service_Order_Line__c createWorkDetailUsage(SVMXC__Service_Order__c wo, String lineType, Product2 prod)
    {
        Id usageRecTypeId = SMAX_PS_Utility.getRecordType('SVMXC__Service_Order_Line__c', 'UsageConsumption').Id;
        SVMXC__Service_Order_Line__c wd = new SVMXC__Service_Order_Line__c(
                            SVMXC__Service_Order__c=wo.Id,
                            RecordTypeId=usageRecTypeId,
                            SVMXC__Line_Type__c = lineType,
                            SVMXC__Product__c = prod.Id,
                            SVMXC__Line_Status__c='Open',
                            SVMXC__Actual_Quantity2__c = 1);
        insert wd;
        return wd;
    }

    public static Product2 createTestProduct(String name, String productCode, String productLine)
    {
        return createTestProduct(name, productCode, productLine, 'Parts');
    }

    public static Product2 createTestProduct(String name, String productCode, String productLine, String prodType)
    {
        return createTestProduct(name, productCode, productLine, prodType, null, null);
    }

    public static Product2 createTestProduct(String name, String productCode, String productLine, String prodType, String uom, String uomCode)
    {
        Product2 p = new Product2();
        p.Name = name;
        p.ProductCode = productCode;
        p.Partnum__c = productCode;
        p.product_line__c = productLine;
        p.SVMXC__Product_Type__c = prodType;
        p.QuantityUnitOfMeasure = uom;
        p.PKI_Qty_UOM_Code__c = uomCode;
        insert p;
        return p;
    }

    public static SVMXC__Product_Stock__c createTestProductStock(SVMXC__Site__c loc, Product2 prod, String status, Integer qty)
    {
        SVMXC__Product_Stock__c ps = new SVMXC__Product_Stock__c();
        ps.SVMXC__Location__c = loc.Id;
        ps.SVMXC__Product__c = prod.Id;
        ps.SVMXC__Status__c = status;
        ps.SVMXC__Quantity2__c = qty;
        ps.SMAX_PS_External_Id__c = loc.SVMX_PS_External_ID__c + '-' + prod.Partnum__c + '-' + status;
        insert ps;
        return ps;
    }

    //Create an Installed Product
    public static SVMXC__Installed_Product__c createIP(String serialNO){
        SVMXC__Installed_Product__c ip = new SVMXC__Installed_Product__c();
        ip.SVMXC__Serial_Lot_Number__c = serialNO;
        insert ip;
        return ip;
    }

    public static SVMXC__Installed_Product__c createIP(String serialNO, Account acct, SVMXC__Site__c loc, String modelSeries)
    {
        return createIP(serialNO, acct, loc, modelSeries, null);
    }

    public static SVMXC__Installed_Product__c createIP(String serialNO, Account acct, SVMXC__Site__c loc, String modelSeries, Product2 prodct)
    {
        SVMXC__Installed_Product__c ip = new SVMXC__Installed_Product__c();
        ip.SVMXC__Company__c = acct.Id;
        ip.SVMXC__Site__c = loc.Id;
        ip.SVMXC__Serial_Lot_Number__c = serialNO;
        ip.SMAX_PS_ModelSeries__c = modelSeries;
        if (prodct != null)
            ip.SVMXC__Product__c = prodct.Id;
        insert ip;
        return ip;
    }

    //Create a Service Contract
    public static SVMXC__Service_Contract__c createSvcMaintContract(String svcName, Id acctId, Date startDate, Date endDate){
        SVMXC__Service_Contract__c sc = new SVMXC__Service_Contract__c();
        sc.Name = svcName;
        sc.SVMXC__Company__c = acctId;
        sc.SVMXC__Start_Date__c = startDate;
        sc.SVMXC__End_Date__c = endDate;
        sc.SVMXC__Active__c = TRUE;
        insert sc;
        return sc;
    }

    //Create a Service Contract
    public static SVMXC__Service_Contract__c createContractItem(SVMXC__Service_Contract__c contract, String svcName, Date startDate, Date endDate){
        SVMXC__Service_Contract__c sc = new SVMXC__Service_Contract__c();
        sc.Name = svcName;
        sc.SVMX_PS_Parent_Contract__c = contract.Id;
        sc.SVMXC__Company__c = contract.SVMXC__Company__c;
        sc.SVMXC__Start_Date__c = startDate;
        sc.SVMXC__End_Date__c = endDate;
        sc.SVMXC__Active__c = TRUE;
        insert sc;
        return sc;
    }

    //Create an SLA
     public static SVMXC__Service_Level__c createSLATerms(String slaName ){
        SVMXC__Service_Level__c sla = new SVMXC__Service_Level__c();
        sla.Name = slaName;
        sla.SVMXC__Onsite_Response_Tracked_On__c = 'Workorder';
        sla.SVMXC__Resolution_Tracked_On__c = 'Workorder';
        sla.SVMXC__Restoration_Tracked_On__c = 'Workorder';
        //Business Hours
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
        sla.SVMXC__Business_Hours__c = bh.id;
        insert sla;
        return sla;
     }

     //Create a Covered Product
     public static SVMXC__Service_Contract_Products__c createCoveredIP(SVMXC__Service_Contract__c sc, Date startDate, Date endDate, SVMXC__Installed_Product__c ip){
        SVMXC__Service_Contract_Products__c cp = new SVMXC__Service_Contract_Products__c();
        cp.SVMXC__Service_Contract__c = sc.Id;
        cp.SVMXC__Start_Date__c = startDate;
        cp.SVMXC__End_Date__c = endDate;
        cp.SVMXC__Installed_Product__c = ip.Id;

        insert cp;
        return cp;

     }

     //Create an Entitlement Date
     public static SMAX_PS_EntitlementDate__c createEntitlementDate(SVMXC__Service_Contract_Products__c cp, SVMXC__Service_Contract_Services__c ent, Date plannedDate){
        SMAX_PS_EntitlementDate__c ed = new SMAX_PS_EntitlementDate__c();
        ed.SMAX_PS_CoveredProduct__c = cp.Id;
        ed.SMAX_PS_Entitlement__c = ent.Id;
        ed.SMAX_PS_PlannedDate__c = plannedDate;
        ed.SMAX_PS_ContractItem__c = cp.SVMXC__Service_Contract__c;
        insert ed;
        return ed;
     }

     //Create an Available Service
     public static  SVMXC__Service__c createAvailableService(String strName){       
        SVMXC__Service__c availService = new SVMXC__Service__c();
        //SVMXC__ServiceMax_Processes__c sp = [SELECT ID from SVMXC__ServiceMax_Processes__c where SVMXC__Name__c = 'SVMXSTD: Generic Type Work Order'];
        availService.SVMXC__Data_Type__c = 'Text';
        availService.SVMXC__Qualifying_Criteria__c = 'a65g0000000976SAAQ';
        availService.Name = strName;
        insert availService;
        return availService;
     }

     //Included Services - called Entitlements
     public static SVMXC__Service_Contract_Services__c createEntitlement(SVMXC__Service_Contract__c sc, String entType, Integer entitledQty, Integer remainingQty){
        SVMXC__Service_Contract_Services__c ent = new SVMXC__Service_Contract_Services__c();
        ent.SVMXC__Service_Contract__c = sc.Id;
        ent.SMAX_PS_EntitlementType__c = entType;
        ent.SMAX_PS_EntitledQty__c = entitledQty;
        ent.SMAX_PS_EntitledQtyRemaining__c = remainingQty;
        ent.SVMXC__Labor_Discount_Covered__c = 100;
        ent.SVMXC__Parts_Discount_Covered__c = 50;
        ent.SVMXC__Travel_Discount_Covered__c = 100;
        ent.SMAX_PS_ConsumableDiscountCovered__c = 75;
        ent.SMAX_PS_ServicePartsDiscountCovered__c = 25;
        insert ent;
        return ent;
     }

     //Create an HSI Custom Setting
     public static SMAX_PS_HSI_Settings__c createHSICustomSetting(String strCountryCode, String strProductLine){
         System.debug('Loading the SMAX_PS_HSI_Settings__c');
         SMAX_PS_HSI_Settings__c hsicstm = new SMAX_PS_HSI_Settings__c();
         hsicstm.Name = strCountryCode + ' - '+ strProductLine;
         hsicstm.SMAX_PS_Active__c = true;
         hsicstm.SMAX_PS_Country_Code__c = strCountryCode;
         hsicstm.SMAX_PS_Product_Line__c = strProductLine;
         insert hsicstm;
         return hsicstm;
     }

    public static SVMXC__RMA_Shipment_Order__c createTestPartsOrder(RecordType recType, Account acct, Contact c, SVMXC__Site__c loc, SVMXC__Service_Group_Members__c tech, SVMXC__Service_Order__c wo, String extId, String relatedExtId)
    {
        SVMXC__RMA_Shipment_Order__c po = new SVMXC__RMA_Shipment_Order__c(RecordTypeId=recType.Id);
        po.SVMXC__Order_Status__c = 'Open';
        po.SVMXC__Expected_Receive_Date__c = Date.today();
        if (acct != null)
        {
            po.SVMXC__Company__c = acct.Id;
        }
        po.SVMXC__Contact__c = c.Id;
        if (loc != null)
        {
            po.SVMXC__Destination_Location__c = loc.Id;
        }
        if (tech != null)
        {
            po.SMAX_PS_Technician__c = tech.Id;
        }
        if (wo != null)
        {
            po.SVMXC__Service_Order__c = wo.Id;
        }
        po.SMAX_PS_RelatedExternalId__c = relatedExtId;
        po.SMAX_PS_ExternalId__c = extId;
        insert po;
        return po;
    }

    public static SMAX_PS_Fault_Code__c createTestFaultCode(String family, String groupVal, String code, String codeDesc, Boolean complaintReq)
    {
        SMAX_PS_Fault_Code_Group__c fcg = new SMAX_PS_Fault_Code_Group__c();
        fcg.SMAX_PS_Code_Family__c = family;
        fcg.SMAX_PS_Code_Group__c = groupVal;
        fcg.SMAX_PS_Code_Group_Type__c = 'Fault Code';
        fcg.Name = groupVal;
        insert fcg;

        SMAX_PS_Fault_Code__c fc = new SMAX_PS_Fault_Code__c();
        fc.SMAX_PS_Fault_Code_Group__c = fcg.Id;
        fc.SMAX_PS_Code_Family__c = family;
        fc.SMAX_PS_Code_Group__c = groupVal;
        fc.SMAX_PS_Code__c = code;
        fc.SMAX_PS_Code_Description__c = codeDesc;
        fc.SMAX_PS_Complaint_Required__c = (complaintReq ? 1 : 0);
        fc.Name = code;
        insert fc;

        return fc;
    }

    public static SMAX_PS_Translation__c createTestTranslation(String name, String countryCode)
    {
        SMAX_PS_Translation__c t = new SMAX_PS_Translation__c();
        t.Name = name;
        t.SMAX_PS_Country__c = countryCode;
        insert t;

        return t;
    }
}