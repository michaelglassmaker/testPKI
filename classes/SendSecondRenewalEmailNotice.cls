public class SendSecondRenewalEmailNotice {
    
    @InvocableMethod
    public static void sendSecondEmail(List<Id> secondEmailOppIds) {        
        List<Opportunity> oppList = [SELECT Id, Opportunity_Primary_Contact_Email_INF__c, Quote_Document_ID__c, Quote_Document_Name__c, Primary_Contact__c FROM Opportunity WHERE Id IN : secondEmailOppIds];
        List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();
        String quoteDocName = oppList[0].Quote_Document_Name__c + '.pdf';
        
        Attachment att = [SELECT Id, Name, Body, ContentType, ParentId FROM Attachment WHERE ParentId =: oppList[0].Id AND Name =: quoteDocName];
        Messaging.EmailFileAttachment fileAttachment = new Messaging.EmailFileAttachment();
        fileAttachment.body = att.Body;
        fileAttachment.contenttype = att.ContentType;
        fileAttachment.filename = att.Name;
        fileAttachment.inline = false;
        fileAttachments.add(fileAttachment);
        
        String emailTemplateName = 'Informatics_Contract_Renewal_Quotation_Template_2nd_Notice';
        String emailService = System.Label.RenewalEmailService;
        
        EmailTemplate emailTemplate = [SELECT Id, Body, Subject from EmailTemplate where DeveloperName = :emailTemplateName LIMIT 1];
        Map<Messaging.SingleEmailMessage, Opportunity> msgToTaskMap = new Map<Messaging.SingleEmailMessage, Opportunity>();
        
        for (Opportunity opportunity : oppList) {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new String[] {oppList[0].Opportunity_Primary_Contact_Email_INF__c};
                message.optOutPolicy = 'FILTER';
            message.setTemplateId(emailTemplate.Id);
            message.setTargetObjectId(oppList[0].Primary_Contact__c);
            message.setWhatId(oppList[0].Id);
            message.setFileAttachments(fileAttachments);
            message.setCcAddresses(new String[] {emailService});
            
            msgToTaskMap.put(message, opportunity);
        }
        
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>(msgToTaskMap.keySet());
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages, false); // Set allOrNothing parameter to true to allow delivery of emails without errors.
        
        for (Messaging.SendEmailResult result : results) {
            if (!result.isSuccess()) {
                System.debug('Send email message failed.');
                for (Messaging.SendEmailError error : result.getErrors()) {
                    System.debug(error.getFields());
                    System.debug(error.getMessage());
                    System.debug(error.getStatusCode());
                    System.debug(error.getTargetObjectId());
                }
            }
            else {
                System.debug('The email was sent successfully.');
            }
        }
    }
    
}