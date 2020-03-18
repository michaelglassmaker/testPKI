global class ContractRenewalEmailService implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env){
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        String myPlainText= '';   
        myPlainText = email.plainTextBody;     
        Task[] newTask = new Task[0];
        String subject = email.Subject;
        String oppId = subject.substringBetween('[', ']');
        String subjectReply = 'Re: ';

        Opportunity opp = [SELECT Id, Customer_Responded__c FROM Opportunity WHERE Id =: oppId];
        try {
            // if EnhancedEmail Perm is enabled, create an EmailMessage object
            EmailMessage emailMessage = new EmailMessage();
            emailMessage.status = '0'; // email was sent
            emailMessage.relatedToId = oppId; // related to record e.g. an opportunity
            emailMessage.fromAddress = email.fromAddress; // from address
            emailMessage.ccAddress = String.join(email.ccAddresses, ';');
            emailMessage.fromName = email.fromName; // from name
            emailMessage.subject = subject; // email subject
            emailMessage.htmlBody = email.htmlBody; // email body
            // Contact, Lead or User Ids of recipients
            // additional recipients who don’t have a corresponding contact, lead or user id in the Salesforce org (optional)
            //emailMessage.toAddress = email.toAddresses[0];
            if(emailMessage.subject.contains(subjectReply)){
                insert emailMessage; // insert            
            }
            if(emailMessage.subject.contains(subjectReply)){
                opp.Customer_Responded__c = true;
            }
            update opp;
        }
        catch (QueryException e) {
            System.debug('Query Issue: ' + e);
        } 
        result.success = true;     
        return result;
    }
}