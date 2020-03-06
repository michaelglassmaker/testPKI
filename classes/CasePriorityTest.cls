@isTest
/*
see  changes in Git Compare View
// voila
// hello_world 123 456
*/

public class CasePriorityTest{
    static testMethod void cloudopsCase(){
        Account acc = CT_TestDataSetupUtility.createTestAccount('TEST','77778','Test');
        insert acc;
        Contact con = CT_TestDataSetupUtility.createTestContact(acc.id,'test','test','test@test.com');
        insert con;
        Case casetoinsert = CT_TestDataSetupUtility.createTestCase('Informatics','New','test','Phone',acc.id,con.id);
        insert casetoinsert;
        Lead leadinsert = new Lead(LastName = 'Test User',
                                   Company = 'Test Company',
                                   Phone = '8005551212',
                                   Fax = '8005551212',
                                   Email = 'sumit.shingavi@cloudsherpas.com',
                                   Street = '123 Main Street',
                                   City = 'Pleasantville',
                                   State = 'New Jersey',
                                   PostalCode = '66666',
                                   Country = 'US',
                                   Status = 'New',INF_Related_case__c=casetoinsert.Id);
        
        
        Case casetoinsert1 = CT_TestDataSetupUtility.createTestCase('CloudOps','New','test','Phone',acc.id,con.id);
        insert casetoinsert1;
        
        Test.startTest();
        Test.setCurrentPage(new PageReference('/apex/MergeCase?id='+casetoinsert1.Id));
        CaseMergeController jpc = new CaseMergeController(new ApexPages.StandardController(casetoinsert1));
        jpc.mrgCase.ParentId = casetoinsert.id;
        jpc.mergecase();
        jpc.cancel();
        Test.stopTest();
    }
}