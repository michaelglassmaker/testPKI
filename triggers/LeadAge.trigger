/*
=======================================================================================================================
Purpose: This Trigger Calculates the Lead Age on Owner Change.
=======================================================================================================================
Change Log:
-----------------------------------------------------------------------------------------------------------------------
VERSION     AUTHOR          DATE            DETAIL                                            
-----------------------------------------------------------------------------------------------------------------------
1.0         JKT             30/10/2012      Initial Development
2.0         Tony Tran       20-NOV-2015     Moved actionable code into Lead_Methods.apxc class
                                            Reformatted LeadAge.apxt trigger header
*/
trigger LeadAge on Lead (after insert,after update, before Insert, Before Update) {

    if((Trigger.isAfter && Trigger.isUpdate) || (Trigger.isBefore && Trigger.isUpdate) || (Trigger.isAfter && Trigger.isInsert))
    {
            if(Utility_Recursive_Check.runOnce())
            {
                //call constructor
                Lead_Methods lm = new Lead_Methods(Trigger.OldMap, Trigger.Old, Trigger.NewMap, Trigger.New);
                lm.Lead_Information_Changed(Trigger.isInsert, Trigger.isUpdate, Trigger.isAfter);
                lm.Record_Date_Time_of_Last_Status_Change (Trigger.isInsert, Trigger.isUpdate, Trigger.isBefore);
            }
    }
    else
    {
        //call constructor
        Lead_Methods lm = new Lead_Methods(Trigger.OldMap, Trigger.Old, Trigger.NewMap, Trigger.New);
        lm.Lead_Information_Changed(Trigger.isInsert, Trigger.isUpdate, Trigger.isAfter);
        lm.Record_Date_Time_of_Last_Status_Change (Trigger.isInsert, Trigger.isUpdate, Trigger.isBefore);
    }
}