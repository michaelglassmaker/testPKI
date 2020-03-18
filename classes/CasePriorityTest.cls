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
        
       
    }
}