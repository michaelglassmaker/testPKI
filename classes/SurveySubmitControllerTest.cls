@isTest
public class SurveySubmitControllerTest{
    static testMethod void SurveySubmitController(){
      
    Account acc = CT_TestDataSetupUtility.createTestAccount('TEST','77778','Test');
    insert acc;
    Contact con = CT_TestDataSetupUtility.createTestContact(acc.id,'test','test','test@test.com');
    insert con;
    Case casetoinsert = CT_TestDataSetupUtility.createTestCase('Informatics','New','test','Phone',acc.id,con.id);
    insert casetoinsert;
    
     Test.startTest();
     Test.setCurrentPage(new PageReference('/apex/SurveyPage?id='+casetoinsert.Id+'&mode=YES'));
     SurveySubmitController  jpc = new SurveySubmitController();
     jpc.initialize(); 
     jpc.getItems();
     jpc.processSurveyCreationForYES();
     Test.stopTest();
    }
    
    static testMethod void SurveySubmitController1(){
      
    Account acc = CT_TestDataSetupUtility.createTestAccount('TEST','77778','Test');
    insert acc;
    Contact con = CT_TestDataSetupUtility.createTestContact(acc.id,'test','test','test@test.com');
    insert con;
    Case casetoinsert = CT_TestDataSetupUtility.createTestCase('Informatics','New','test','Phone',acc.id,con.id);
    insert casetoinsert;
    
     Test.startTest();
     Test.setCurrentPage(new PageReference('/apex/SurveyPage?id='+casetoinsert.Id+'&mode=NO'));
     SurveySubmitController  jpc = new SurveySubmitController();
     jpc.initialize(); 
     jpc.comments ='Test';
     jpc.selectedvalue = 'Others';
     jpc.getItems();
     jpc.processSurveyCreationForNO();
     Test.stopTest();
    }
    
    static testMethod void SurveySubmitController2(){
      
    Account acc = CT_TestDataSetupUtility.createTestAccount('TEST','77778','Test');
    insert acc;
    Contact con = CT_TestDataSetupUtility.createTestContact(acc.id,'test','test','test@test.com');
    insert con;
    Case casetoinsert = CT_TestDataSetupUtility.createTestCase('Informatics','New','test','Phone',acc.id,con.id);
    insert casetoinsert;
    INF_Case_Survey__c survey = new INF_Case_Survey__c(Case__c = casetoinsert.id,INF_Support_Sat_No__c =true,INF_Support_sat_Comments__c ='test',INF_Support_Sat_Bin__c='Others',INF_Recently_Created_Survey__c=true);
    insert survey;
    
     Test.startTest();
     Test.setCurrentPage(new PageReference('/apex/SurveyPage?id='+casetoinsert.Id+'&mode=NO'));
     SurveySubmitController  jpc = new SurveySubmitController();
     jpc.initialize(); 
     jpc.comments ='Test';
     jpc.selectedvalue = 'Others';
     jpc.getItems();
     jpc.processSurveyCreationForNO();
     Test.stopTest();
    }
    
    static testMethod void SurveySubmitController3(){
      
    Account acc = CT_TestDataSetupUtility.createTestAccount('TEST','77778','Test');
    insert acc;
    Contact con = CT_TestDataSetupUtility.createTestContact(acc.id,'test','test','test@test.com');
    insert con;
    Case casetoinsert = CT_TestDataSetupUtility.createTestCase('Informatics','New','test','Phone',acc.id,con.id);
    insert casetoinsert;
    INF_Application__c app = new INF_Application__c(Name='test',INF_Product_Group__c='CBOE',INF_Product_Line__c ='test');
    insert app;
    INF_Case_Application__c caseapp = new INF_Case_Application__c(Application__c=app.id,Case__c = casetoinsert.id);
    insert caseapp;
    INF_Case_Survey__c survey = new INF_Case_Survey__c(Case__c = casetoinsert.id,INF_Support_Sat_Yes__c = true,INF_Recently_Created_Survey__c=true);
    insert survey;
    
     Test.startTest();
     Test.setCurrentPage(new PageReference('/apex/SurveyPage?id='+casetoinsert.Id+'&mode=YES'));
     SurveySubmitController  jpc = new SurveySubmitController();
     jpc.initialize(); 
     jpc.getItems();
     jpc.processSurveyCreationForYES();
     String a = jpc.getselectedvalue();
     jpc.setselectedvalue('a');
     jpc.processSurveyCreation();
     jpc.getYesItems();
     Test.stopTest();
    }
}