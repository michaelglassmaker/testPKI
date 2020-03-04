public class SendFinalRenewalEmailNotice {
    
    @InvocableMethod
    public static void sendFinalEmail(List<Id> thirdEmailOppIds) {        
        List<Opportunity> oppList = [SELECT Id, Opportunity_Primary_Contact_Email_INF__c, Quote_Document_ID__c, Quote_Document_Name__c, Primary_Contact__c FROM Opportunity WHERE Id IN : thirdEmailOppIds];
        List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();
        String quoteDocName = oppList[0].Quote_Document_Name__c + '.pdf';
        
        Attachment att = [SELECT Id, Name, Body, ContentType, ParentId FROM Attachment WHERE ParentId =: oppList[0].Id AND Name =: quoteDocName];
        Messaging.EmailFileAttachment fileAttachment = new Messaging.EmailFileAttachment();
        fileAttachment.body = att.Body;
        fileAttachment.contenttype = att.ContentType;
        fileAttachment.filename = att.Name;
        fileAttachment.inline = false;        
        fileAttachments.add(fileAttachment);
        
        List<EmailTemplate> templatesList = [SELECT Id, Body, Subject from EmailTemplate where DeveloperName = 'Informatics_Contract_Renewal_Quotation_Template_3rd_Notice'];
        String emailService = System.Label.RenewalEmailService;
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] {oppList[0].Opportunity_Primary_Contact_Email_INF__c};
            message.optOutPolicy = 'FILTER';
        message.setTemplateId(templatesList[0].Id);
        message.setTargetObjectId(oppList[0].Primary_Contact__c);
        message.setWhatId(oppList[0].Id);
        message.setFileAttachments(fileAttachments);
        message.setCcAddresses(new String[] {emailService});
        Messaging.SingleEmailMessage[] messages = 
            new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: '
                         + results[0].errors[0].message);
        }
        
    }
    
    
    
}