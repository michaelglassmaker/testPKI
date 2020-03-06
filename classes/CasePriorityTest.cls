@isTest
/*
see  changes in Git Compare View
// voila
// hello_world 123 456
*/

public class CasePriorityTest{
    
    @testSetup static void setup() {
SAI_Lead_Routing_Values__c cc = new SAI_Lead_Routing_Values__c();
cc.SAI_Values__c = 'Applied Genomics, Maternal Fetal Health, Newborn Screening';
 insert cc;
 }
    static testMethod void cloudopsCase(){
        Account acc = CT_TestDataSetupUtility.createTestAccount('TEST','77778','Test');
        insert acc;
        Contact con = CT_TestDataSetupUtility.createTestContact(acc.id,'test','mjgmjg02@test.com');
        insert con;
        Case casetoinsert = CT_TestDataSetupUtility.createTestCase('Cloud Operations','New','Phone',acc.id,con.id);
        insert casetoinsert;
}
