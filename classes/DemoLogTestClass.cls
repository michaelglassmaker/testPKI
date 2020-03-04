@isTest
public class DemoLogTestClass {
	@isTest
    public static void TestDemoLogExpiration(){
        PageReference p = Page.DemoLogExpiration;
        test.setCurrentPage(p);
        
        Demo_Log__c d = new Demo_Log__c();
        d.RecordTypeId = Schema.getGlobalDescribe().get('Demo_log__c').getDescribe().getRecordTypeInfosbyName().get('System Request').getRecordTypeid();
		d.Primary_Product_INF__c = 'Registration';
        d.Expiration_Date__c = Date.today();
        insert d;
        
       ApexPages.currentPage().getParameters().put('Id',d.id);
       ApexPages.currentPage().getParameters().put('Days','30 Days');
       ApexPages.currentPage().getParameters().put('typ','Parked'); 
       ApexPages.currentPage().getParameters().put('Status','OFF');  
        
        DemoLogExpirationController dc = new DemoLogExpirationController();
        dc.submit();
        
    }
}