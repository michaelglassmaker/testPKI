/*
        Class:        EmailMessageTrigger
        @Author:        
        @Created Date:  11/10/2013
        @Description:   Email Message Trigger
Change History
****************************************************************************************************************************
    ModifiedBy      Date        Jira         Requested By                            Description                           Tag
****************************************************************************************************************************
               
*/
trigger EmailMessageTrigger on EmailMessage (before insert,before update,after insert) {
    EmailMessageMethods em = new EmailMessageMethods();
     if(Trigger.isBefore && (Trigger.isInsert||Trigger.isUpdate)) {
        em.Trg_emailmessage(trigger.new);
    }
    if(Trigger.isBefore && Trigger.isInsert) {
        em.AppendCaseNumberToSubject(trigger.new,Trigger.isInsert);
        em.ParseEmail(trigger.new,Trigger.isInsert);
    }
}