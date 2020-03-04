@isTest
public class Test_Lockrecord{
  @isTest 
  public static void LockQuote(){
     List<SBQQ__Quote__c> Quotes = new List<SBQQ__Quote__c>();
     List<SBQQ__QuoteLine__c> QuoteLines = new List<SBQQ__QuoteLine__c>();
     List<Id> Quote_ids = new List<Id>();
     Integer i =0;
     Product2 p = new Product2();
     p.Name = 'Test product';
     insert p;
     for(i=0;i<=10;i++){
         SBQQ__Quote__c q= new SBQQ__Quote__c();
         q.SBQQ__StartDate__c= Date.Today();
         Quotes .add(q);
         
         
     }
     insert Quotes;
     for(SBQQ__Quote__c q: Quotes){
        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
        ql1.SBQQ__Quote__c = q.id;
        ql1.SBQQ__Product__c = p.id;
        ql1.SBQQ__Quantity__c = 2 + i;
        QuoteLines .add(ql1);
        Quote_ids.add(q.id);
     }
     insert QuoteLines;
     LockRecord.lockRecords(Quote_ids);
     
     for(SBQQ__Quote__c q: Quotes){
        System.assertEquals(Approval.isLocked(Q.id),true);
     }
     for(SBQQ__QuoteLine__c  ql: QuoteLines){
        System.assertEquals(Approval.isLocked(ql.id),true);
     }
  }

}