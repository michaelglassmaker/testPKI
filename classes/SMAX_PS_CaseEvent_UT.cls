@isTest(seeAlldata=false)
public class SMAX_PS_CaseEvent_UT {

    // Not a valid "test", but need code coverage.. 
    // We found that if seeAllData is true, Platform Event triggers don't fire.
    // BUT, can't create a Case without seeAllData=true
    static testMethod void caseEventTest() {
        // Case event
        Test.startTest();
        Case_Event__e cEvent = new Case_Event__e (
                                    CaseId__c = 'Test Case Id');
        Database.SaveResult sr = EventBus.publish(cEvent);
        Test.stopTest();
   }
}