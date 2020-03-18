/**********************************************************************************************************************
Name: LeadAssign 
Copyright © 2012 PerkinElmer | Salesforce Instance
=======================================================================================================================
Purpose: This Trigger auto assigns a assignment rule to a Lead.
         To execute the DML statements it adopted a Class Reference.
=======================================================================================================================
REQUIREMENT INFORMATION & DEVELOPMENT INFORMATION:                                                         
-----------------------------------------------------------------------------------------------------------------------
VERSION AUTHOR                DATE       DETAIL                                            
-----------------------------------------------------------------------------------------------------------------------
1.0     Prasannajeet Parida   31/08/2012 Initial Development - SF2SF                       
**********************************************************************************************************************/
trigger LeadAssign on Lead (after update) {
  List<Id> lIds=new List<id>();
   if(Trigger.isAfter){
        //Collecting all the new updating Lead Ids.
        For (lead l:trigger.new){
            if (l.IsConverted==False){
                lIds.add(l.Id);            
            }
        }
        //Checks wheather the Class previously Called or not
        if (AssignLeads.assignAlreadyCalled()==FALSE){
            AssignLeads.Assign(lIds);
        }
   }
}