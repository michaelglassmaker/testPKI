/******************************************************************************
 * Name:        LeadAfter 
 *
 * Purpose:     Master Trigger to fire ON ALL AFTER events of Lead records. 
 *              Follows the super trigger framework to control the order in which trigger actions occur.
 *              
 * @Author:     Abdul Sattar (Magnet 360)
 * @Date:       01.02.2015
 *
 * @Updates:
 * 
 ******************************************************************************/
trigger LeadAfter on Lead(after insert, after update) {
    
    if (Trigger.isUpdate) {
        // Create lead aging track on lead updates.
        TriggerLead.createLeadAgingTrack(Trigger.New, Trigger.Old);
        
        // Create lead interest track for lead on both insert & update events.
        TriggerLead.createLeadInterestTrack(Trigger.NewMap, Trigger.OldMap);

        // Create Forms Qualificaion History on lead updates.
        TriggerLead.createFormsQualificationHistory(Trigger.NewMap, Trigger.OldMap);
    }
}