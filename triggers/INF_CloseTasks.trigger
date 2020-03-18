trigger INF_CloseTasks on Opportunity (after update) 
{
    List<Id> OppIds = new List<Id>();
  
    for(Opportunity o: trigger.new)
    {
        if(o.RecordTypeId == Utility_Informatics.opportunity_Informatics)
        {
            If(o.StageName == 'Closed Won' || o.StageName == 'Closed Lost')
            {
            OppIds.add(o.Id);
            
            }
         }
    }
    
    List<Task> TasksToClose = new List<Task>();
    
    for(Task t:[select Id,WhatId,Status from Task where WhatId IN :OppIds AND Status not in ('Completed','Call Completed')])
    {
        t.Status = 'Completed';
        TasksToClose.add(t);
    }
    
    if(TasksToClose.size() > 0)
       update TasksToClose;
}