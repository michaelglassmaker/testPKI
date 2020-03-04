public class SubmitOrderController {
    public Opportunity currentRecord{get; set;}
    public boolean validate=false;
    public SubmitOrderController(ApexPages.StandardController controller) {
        currentRecord = [SELECT Id, Name, AccountId,Contract_Request__c,Renewal_Required_INF__c,StageName FROM Opportunity WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
        Profile p = [Select Name from Profile where Id =: userinfo.getProfileid()];
        String pname = p.name;
       // validate=true;
        if (currentRecord.AccountId == '0013000001DIl1y' &&  string.isblank(currentRecord.Contract_Request__c)){
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'All orders to be sent to Contracts for review before processing'));validate=false;
        }
        if(string.isblank(currentRecord.Renewal_Required_INF__c)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Submission is rejected due to Renewal Required field empty or null'));validate=false;
        }
        if (currentRecord.StageName == 'Stage 6 - Implement (Closed)' || currentRecord.StageName == 'Closed Won' || currentRecord.StageName  == 'Closed Lost' || pname == 'Informatics Operations'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid Operation'));validate=false;
        }
        if(pname != 'Informatics Operations' ){
            validate=true;
        }  
}
Public void UpdateOpp(){
    if(validate==true){
    currentRecord.StageName='Stage 6 - Implement (Closed)';
           currentRecord.Order_Processing_Status_INF__c='Submitted';
           try{
               Update currentRecord;
               if(currentRecord.StageName=='Stage 6 - Implement (Closed)'){
                  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Order Submitted Successfully.'));

               }
           }
           catch(Exception e){ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Error in Submission: '+e.getmessage()));}
}
}
}