public without sharing class LockRecord {

    @InvocableMethod
    public static void lockRecords(List<Id> QuoteList)
    {
            List<SBQQ__Quote__c> QuoteId = new List<SBQQ__Quote__c>();
            List<SBQQ__QuoteLine__c> QuoteLines = new List<SBQQ__QuoteLine__c>();
            
            QuoteId = [Select id,Approval_Locked__c from SBQQ__Quote__c where id=:QuoteList];
            if(QuoteId.size()>0)
            {
                QuoteLines = [select id from SBQQ__QuoteLine__c where SBQQ__Quote__c=:QuoteId];
                Approval.LockResult[] lrOptyList = Approval.lock(QuoteId, false);
            }
            if(QuoteLines.size()>0)
            {
                Approval.LockResult[] lrList = Approval.lock(QuoteLines, false);
            }
            
    }
}