@isTest(seeAllData=true)
public class quote_trgTest {
    static testMethod void Test_Method1(){
        Account a = new Account(Name='Testing3456',shippingCountry='US',Industry ='Biotech',
                                BillingStreet='Street1',BillingCity='City1',BillingState='State',BillingCountry='US',BillingPostalCode='12345');
        insert a;
        Opportunity op = new Opportunity(Name='opp1',AccountId=a.Id,RecordTypeId='01230000001aIi6',
                                              Renewal_Required_INF__c='Yes',Account_Type_INF__c='Academic',
                                              StageName='Stage 1 - Create/Plan',CloseDate=Date.today(),
                                              Strategic_Market_INF__c='Clinical',Type='New Account',
                                              ForecastCategoryName='Pipeline',CurrencyIsoCode = 'USD',
                                        	  Solution_Area_of_Interest__c='Energy');        
        insert op;
        SBQQ__Quote__c q = new SBQQ__Quote__c(Quote_Name__c='Q1213',SBQQ__Primary__c=true,SBQQ__StartDate__c=Date.today(),
                                              SBQQ__Account__c=a.Id,SBQQ__Opportunity2__c=op.Id,ApprovalStatus__c='Pending');
        insert q;
    }
}