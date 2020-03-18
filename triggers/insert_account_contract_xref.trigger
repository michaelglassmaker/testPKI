trigger insert_account_contract_xref on Contract (after insert) {
   Account_Contract_Junction_Object__c  xref = new Account_Contract_Junction_Object__c();
   for (contract c: trigger.new) {
      xref.Account_Relationship__c = c.accountid;
      xref.Contract_Relationship_1__c = c.id;
      insert xref;
   }
}