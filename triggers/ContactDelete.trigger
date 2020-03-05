trigger ContactDelete on Contact (after delete,before delete) {
    if(Trigger.isBefore && Trigger.isDelete){
        for (Contact c : Trigger.old) {
            if (c.PKI_SAP_Customer_Number__c != null) {
                c.addError('You cannot delete SAP contact!');
            } 
        }
    }
}