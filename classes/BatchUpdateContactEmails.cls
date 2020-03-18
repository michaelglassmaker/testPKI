global class BatchUpdateContactEmails implements Database.batchable<sObject>, Database.Stateful,Schedulable,Database.AllowsCallouts{
    // retain state across transactions
    global Integer recordsProcessed = 0;
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        set<string> setOfDomain = new set<string>();
        setOfDomain.add('%'+'.invalid'+'%');
        String strquery = 'Select ID, Email FROM Contact where Email <> null AND (NOT Email LIKE:setOfDomain)';
        return Database.getQueryLocator(strquery);
    }
    global void execute(Database.BatchableContext bc, List<Contact> scope){
        // process each batch of records
        List<Contact> lstUpdcontacts = new List<Contact>();
     
        //loop through sObject member
        for (Contact oContact : scope) {
            oContact.Email = oContact.Email+'.invalid';
            //add contact to list to be updated
            lstUpdcontacts.add(oContact);
            //increment the instance member counter
            recordsProcessed = recordsProcessed + 1;
        }
        update lstUpdcontacts;
    }    
    global void finish(Database.BatchableContext bc){
        
// Now create a new single email message when Batch job completes
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

// Email addresses to which you are sending the email.
String[] toAddresses = new String[] {'michael.glassmaker@perkinelmer.com'}; 

// Assign the addresses for the To and CC lists to the mail object.
mail.setToAddresses(toAddresses);

// Specify the address used when the recipients reply to the email. 
mail.setreplyto('michael.glassmaker@perkinelmer.com');

// Specify the name used as the display name.
mail.setSenderDisplayName('MG');

// Specify the subject line for your email address.
mail.setSubject('BATCH UPDATE COMPLETE');

// Specify the text content of the email.
mail.setPlainTextBody('The Batch Update of ALL Contact Email Addresses to  .invalid  has completed');

mail.setHtmlBody('The Batch Update of ALL Contact Email Addresses to  .invalid  has completed');

// Send the email you have created.
Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    } 
       
    global void execute(SchedulableContext ctx) {  
        //Call batch class
        BatchUpdateContactEmails BatchUpdateContactEmails =new BatchUpdateContactEmails();
        ID batchprocessid = Database.executeBatch(batchUpdateContactEmails,2000);
    }
}