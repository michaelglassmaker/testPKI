/******************************************************************************
 * Name:        ContactBefore 
 *
 * Purpose:     Master Trigger to fire ON ALL BEFORE events of Contact records. 
 *              Follows the super trigger framework to control the order in which trigger actions occur.
 *
 * @Author:     Abdul Sattar (Magnet 360)
 * @Date:       01.02.2015
 *
 * @Updates:
 * 
 ******************************************************************************/
trigger ContactBefore on Contact(before insert, before update) {
    if (Trigger.isUpdate) {
        //modified by Tony Tran on JUN-15-2016 to comment out the line that calls
        //TriggerContact.interceptContactModifications since the class in Production
        //does not have this method.
        // Intercept contact updates from Pardot and reject if Allow Sync = FALSE
        //TriggerContact.interceptContactModifications(Trigger.New, TRUE);

        // Intercept contact updates from Pardot Prospect and apply custom logic
        TriggerContact.interceptContactUpdates(Trigger.New, Trigger.oldMap);
    }
}