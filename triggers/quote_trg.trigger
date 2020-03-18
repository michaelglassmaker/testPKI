trigger quote_trg on SBQQ__Quote__c (before update) {
    List<ID> oppIds = new List<ID>();
    for(SBQQ__Quote__c o:Trigger.new){
        if(o.SBQQ__Primary__c==true && o.ApprovalStatus__c!=null && o.SBQQ__Opportunity2__c!=null){
            oppIds.add(o.SBQQ__Opportunity2__c);
        }
    }
    List<Opportunity> lstOpps = [Select Id,sbaa__ApprovalStatus__c FROM Opportunity WHERE Id=:oppIds];
    Map<ID,Opportunity> mapIO = new Map<ID,Opportunity>();
    for(Opportunity o: lstOpps){mapIO.put(o.Id,o);}
    for(SBQQ__Quote__c o:Trigger.new){
        if(o.SBQQ__Primary__c==true && o.ApprovalStatus__c!=null && o.SBQQ__Opportunity2__c!=null){
            Opportunity T = mapIO.get(o.SBQQ__Opportunity2__c);
            T.sbaa__ApprovalStatus__c = o.ApprovalStatus__c;
        }
    }
    if(lstOpps.size()>0){update lstOpps;}
}