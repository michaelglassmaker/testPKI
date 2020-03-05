trigger UpdateLeadStatus on Task (after insert) {
Set<ID> leadId = new Set<Id>();
List<Lead> leadsToUpdate = new List<Lead>();
//Obtain the keyprefix of lead object
private static String LEAD_PREFIX = Schema.SObjectType.Lead.getKeyPrefix();

//Iterate through trigger.new and obtain the list of leads to be updated
for(Task t : Trigger.new){
    if(t.whoId != null){
        String whoId = (String)t.whoId;
        if(whoId.startsWith(LEAD_PREFIX)){
            leadId.add(t.whoId);
        }
    }
}

//Query only the leads whose status is 'Open' and update its status to 'Working'
if(leadId.size() > 0){
    for(Lead l : [Select Id, Status from Lead where Id in: leadId and Status = 'Open' and eq_Is_Eloqua_Lead__c !=true]){
        l.Status = 'Working';
        leadsToUpdate.add(l);
    }
    if(leadsToUpdate.size() > 0)
        update(leadsToUpdate);
}
}