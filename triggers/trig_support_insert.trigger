trigger trig_support_insert on Support__c (before insert, before update) {
for (support__c o: Trigger.new) 
 { 
o.Email2HelpDesk__c = o.HelpDesk_Email__c; 
  }
}