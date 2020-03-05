/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Title           : trigger_OnTask
Author          : Lister Technologies
Description     : This is a trigger on Task which calls out handler classes.
Test Class      : 
Created on      : May 8th 2017
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
/***********************************************************************************************************/
/*|S.N0|-----------Description---------|--Modified On--|--Modified By--|--Tag--|-----------Test Class-------|
/***********************************************************************************************************/
/*|    |                               |               |               |       |                            |
/*|    |                               |               |               |       |                            |
/*|    |                               |               |               |       |                            |
/***********************************************************************************************************/
trigger trigger_OnTask on Task (after insert, after update) {
    if(trigger.isInsert || trigger.isUpdate){
        Handler_PopulateApproverOnOpportunity handler1 = new Handler_PopulateApproverOnOpportunity(trigger.new,trigger.oldmap,trigger.isInsert);
        handler1.updateLeaders();
    }
}