trigger UpdateLeadStatusForNotes on Note (after insert) {
Set<ID> leadId = new Set<Id>();
List<Lead> leadsToUpdate = new List<Lead>();
//Obtain the keyprefix of lead object
private static String LEAD_PREFIX = Schema.SObjectType.Lead.getKeyPrefix();

//Iterate through trigger.new and obtain the list of leads to be updated
for(Note n : Trigger.new){
    if(n.ParentId != null){
        String parentId = (String)n.ParentId;
        if(parentId.startsWith(LEAD_PREFIX)){
            leadId.add(n.ParentId);
        }
    }
}

//Query only the leads whose status is 'Open' and update its status to 'Working'
if(leadId.size() > 0){
    for(Lead l : [Select Id, Status from Lead where Id in: leadId and Status = 'Open']){
        l.Status = 'Working';
        leadsToUpdate.add(l);
    }
    if(leadsToUpdate.size() > 0)
        update(leadsToUpdate);
}
}