/*
Class:        DelOppLineTrigger
@Author:        
@Created Date:  11/10/2013
@Description:   Trigger for OpportunityLineItem
Change History
****************************************************************************************************************************
ModifiedBy      Date        Jira         Requested By                            Description                           Tag
****************************************************************************************************************************
11/10/2013  Shashi Merge Email Message triggers with changes done in Full SB    <T01>
*/
trigger DelOppLineTrigger on OpportunityLineItem (before delete) {
    if(Trigger.isBefore && Trigger.isDelete) {
        List<DeletedRecords__c> dRec = new List<DeletedRecords__c>();
        for(OpportunityLineItem o:Trigger.old){
            DeletedRecords__c d=new DeletedRecords__c();
            d.name = o.Id;
            d.Object__c = 'OpportunityLineItem';
            dRec.add(d);            
        }
        if(dRec.size()>0)
            insert dRec;
    }
}