@isTest
private class test_revenue_rec_date_populatee
{
  static testMethod void testinsert() {
    //create opportunity
    opportunity test_o = new opportunity();
    test_o.Name = 'Test';
    test_o.StageName = 'Abandoned';
    test_o.CloseDate = date.parse('3/10/2012');
    test_o.Revenue_rec_date__c = date.parse('3/1/2012');
    test_o.Market_Segment__c = 'Duplicate';
    test_o.Type = 'New Business';                                       
     insert test_o;                                    
    }
    static testmethod void testDealerPortal(){
       profile p = [select Id from Profile where Name = 'Dx Partner Community user'];
       Account a = new Account(Name='Test Account Name');
      insert a;
       Contact c = new contact(lastName='User',FirstName = 'Test',email = 'testuser3689@test.com', AccountId = a.Id);
       insert c;
        User u = new user(lastname = 'User' ,FirstName = 'test', username = 'testuser3689@test.com',profileId = p.Id
                         ,Email = 'testuser3689@test.com',Alias = 'tuser2',TimeZoneSidKey = 'America/new_york'
                         ,LocaleSidKey = 'en_US',EmailEncodingKey = 'UTF-8',LanguageLocaleKey='en_US',contactid = c.id);
        insert u;
        RecordType r = [select Id from RecordType Where DeveloperName = 'Dx_GBL_Opportunity_Record_Type'];
        Opportunity O = new Opportunity();
            o.name = 'test opp';
            O.StageName = 'Stage 1 - Qualification';
            o.RecordTypeId = r.id;
            o.CloseDate = Date.today().adddays(5);
        System.runAs(u){            
            insert o;
            o.StageName = 'Stage 4 - Objection Handling';
            update o;
            }
        Opportunity o1 = new Opportunity();
        o.name = 'test opp';
            o1.Name = 'test 2';
            o1.StageName = 'Stage 4 - Objection Handling';
            o1.RecordTypeId = r.id;
            o1.CloseDate = Date.today().adddays(5);
        insert o1;
       
            o1.StageName = 'Closed Won';
            update o1;

     
    }
 }