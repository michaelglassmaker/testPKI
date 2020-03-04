public class DemoLogExpirationController {
    public String Did {get;set;}
    public String DemologName {get;set;}
    public String ActDays {get;set;}
    Public String Type {get;set;}
    Public String Status {get;set;}  
    Public Demo_Log__c d;
    public DemoLogExpirationController(){

        Did = ApexPages.currentPage().getparameters().get('Id');
        d = [Select id,Name,System_Days_Active__c,Default_Status__c,Type2__c From Demo_Log__c Where Id = :Did];
        DemologName = d.Name;
        ActDays = ApexPages.currentPage().getparameters().get('Days');
        Type = (ApexPages.currentPage().getparameters().get('typ') != 'null')?(ApexPages.currentPage().getparameters().get('typ')):d.Type2__c;
        Status = (ApexPages.currentPage().getparameters().get('Status') != 'null')?(ApexPages.currentPage().getparameters().get('Status')):d.Default_Status__c;

     }
    public PageReference submit(){
        d.System_Days_Active__c = ActDays;
        d.Type2__c = Type;
        d.Default_Status__c = Status;
        update d;
        pageReference p = new PageReference('/' + d.id);
        p.setRedirect(true);
        return p;
    }
}