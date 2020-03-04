/*
Name        : LaunchCPQExtTest
Author      : Anila Khwaja
Date        : 21-Nov-2013
Version     : 1.0
Description : This class is used to redirect user to CPQ Opportunity page
*/
@isTest
private with sharing class LaunchCPQExtTest {

    /*-----------------VARIABLES---------------------*/
    private static ApexPages.StandardController controller;
    private final static  string FPX_CPQ_SANDBOX_URL = 'CPQ-Sandbox-Server';
    private final static string FPX_CPQ_PRODUCTION_URL = 'CPQ-Production-Server';
    private final static string PRODUCTION = 'Production';
    private final static string SANDBOX = 'Sandbox';
    private final static string ACCOUNT_OBJ = 'Account';
    private final static string OPP_OBJ = 'Opportunity';
 
    
    /************************CREATE Global Setting***************************/
    static map<string,firepond__Global_Setting__c> CreateGlobalSetting()
    {
        map<string, firepond__Global_Setting__c> lst = new map<string,firepond__Global_Setting__c>();
        
        lst.put(FPX_CPQ_PRODUCTION_URL,
            new firepond__Global_Setting__c(Name=FPX_CPQ_PRODUCTION_URL, firepond__Setting_Value__c='https://stg.fpx.com'));
        
        lst.put(FPX_CPQ_SANDBOX_URL,
            new firepond__Global_Setting__c(Name=FPX_CPQ_SANDBOX_URL, firepond__Setting_Value__c='https://stg.fpx.com'));
      
        lst.put('Publish_EndPoint',
            new firepond__Global_Setting__c(Name='Publish_EndPoint', firepond__Setting_Value__c='http://starterkit.fpx.com/starterkit/rest/1/publish'));
        
        
        insert lst.values();
        
        return lst;
    }
    
     /************************CREATE CONTEXT VARIABLE***************************/
    static list<firepond__Context_Variable__c> CreateContextVariable()
    {
        list<firepond__Context_Variable__c> lstOfCV = new list<firepond__Context_Variable__c>();
        
        lstOfCV.add(new firepond__Context_Variable__c(Name='Var1', firepond__Object__c=ACCOUNT_OBJ, firepond__Variable_Value__c='Name', firepond__Default__c = 'var'));
        lstOfCV.add(new firepond__Context_Variable__c(Name='Var2', firepond__Object__c=OPP_OBJ, firepond__Variable_Value__c='StageName', firepond__Default__c = 'var'));
        lstOfCV.add(new firepond__Context_Variable__c(Name='Var3', firepond__Object__c=OPP_OBJ, firepond__Variable_Value__c='Name', firepond__Default__c = 'var'));
        
        insert lstOfCV;
        
        return lstOfCV;
    }
    
    /************************CREATE Opportunity***************************/
    static list<Opportunity> CreateAccountOpportunity(integer aNumberOfItems)
    {
        if(aNumberOfItems == null || aNumberOfItems <= 0)
            aNumberOfItems = 1;
            
        list<Account> listOfAcc = CreateAccount(aNumberOfItems);
        list<Opportunity> listOfOpp = new list<Opportunity>(); 
        
        for(integer index=0; index < aNumberOfItems; index++)
            listOfOpp.add(new Opportunity(Name='Var' + index, AccountId = listOfAcc.get(index).Id, StageName='Closed-Won', CloseDate=Date.today(),Solution_Area_of_Interest__c='Energy'));
        
        insert listOfOpp;
        
        return listOfOpp;
    }
    
    /************************CREATE Account***************************/
    public static list<Account> CreateAccount(integer aNumberOfItems)
    {
        if(aNumberOfItems == null || aNumberOfItems <= 0)
            aNumberOfItems = 1;
            
        list<Account> listOfAcc = new list<Account>(); 
        
        for(integer index=0; index < aNumberOfItems; index++)
            listOfAcc.add(new Account(Name='Var' + index));
        
        insert listOfAcc;
        
        return listOfAcc;
    }
    
    //for launch cpq page
    static testMethod void LaunchCPQTest() 
    {
        //create context variable
        map<string,firepond__Global_Setting__c> mapOfGS = CreateGlobalSetting();
        List<firepond__Context_Variable__c> listOfCV = CreateContextVariable();
        list<Opportunity> listOfOpp = CreateAccountOpportunity(1);
        
        Test.startTest();
        
        controller = new ApexPages.StandardController(listOfOpp.get(0));
        ApexPages.currentPage().getParameters().put('server', PRODUCTION);
        LaunchCPQExt op = new LaunchCPQExt(controller);
        PageReference pg = op.action();
                
        controller = new ApexPages.StandardController(listOfOpp.get(0));
        ApexPages.currentPage().getParameters().put('server', SANDBOX);
        op = new LaunchCPQExt(controller);
        PageReference pg1 = op.action();
        
        Test.stopTest();
        
        //check is page returning CPQ url
        System.assertEquals(pg.getUrl().contains(mapOfGS.get(FPX_CPQ_PRODUCTION_URL).firepond__Setting_Value__c),true);
        System.assertEquals(pg1.getUrl().contains(mapOfGS.get(FPX_CPQ_SANDBOX_URL).firepond__Setting_Value__c),true);
    }
    
}