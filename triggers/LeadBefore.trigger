/******************************************************************************
 * Name:        LeadBefore 
 *
 * Purpose:     Master Trigger to fire ON ALL BEFORE events of Lead records. 
 *              Follows the super trigger framework to control the order in which trigger actions occur.
 *              
 * @Author:     Abdul Sattar (Magnet 360)
 * @Date:       01.02.2015
 *
 * @Updates:    
 *
 * 09.02.2015   Abdul Sattar (Magnet 360)
 *              Updated to allow duplicate lead creation from Sales Force UI.
 *
 * 11.12.2015   Abdul Sattar (Magnet 360)
 *              Code clean up
 *
 * 11.19.2015   Abdul Sattar (Magnet 360)
 *              Updated to intercept lead inserts from Pardot and reject if needed
 * 
 ******************************************************************************/
trigger LeadBefore on Lead(before insert, before update) {

    if (Trigger.isInsert && !Trigger.isDelete)  {
        //modified by Tony Tran on JUN-15-2016 to comment out the line that calls
        //TriggerLead.interceptLeadModifications since the class in Production
        //does not have this method.
        // Intercept Lead inserts from Pardot and reject if Allow Sync = FALSE
        //TriggerLead.interceptLeadModifications(Trigger.New, FALSE);

        // Set Override_Duplicate_Error__c = true to allow duplicate leads
        TriggerLead.overrideDuplicateErrorFromSF(Trigger.New);
    }

    if (Trigger.isUpdate) {
        //modified by Tony Tran on JUN-15-2016 to comment out the line that calls
        //TriggerLead.interceptLeadModifications since the class in Production
        //does not have this method.
        // Intercept Lead updates from Pardot and reject if Allow Sync = FALSE
        //TriggerLead.interceptLeadModifications(Trigger.New, TRUE);

        // Intercept lead updates from Sales Force UI and apply custom logic
        TriggerLead.interceptLeadUpdatesFromSF(Trigger.New);
        
        // Intercept lead updates from Pardot Prospect and apply custom logic
        TriggerLead.interceptLeadUpdates(Trigger.New, Trigger.oldMap);

        // Set create date.
        TriggerLead.setCreateDateOnStatusChagne(Trigger.New, Trigger.OldMap);
    }
}