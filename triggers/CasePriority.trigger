trigger CasePriority on Case (before Insert) {

        if(trigger.isInsert && trigger.isBefore){
    
      for (Case obj: trigger.new) {
        if(obj.Subject.Contains('Priority1'))
            obj.Priority = 'P1';
        }
        
         if(trigger.isInsert && trigger.isBefore){
    
      for (Case obj: trigger.new) {
        if(obj.Subject.Contains('Priority2'))
            obj.Priority = 'P2';
        }
        
         if(trigger.isInsert && trigger.isBefore){
    
      for (Case obj: trigger.new) {
        if(obj.Subject.Contains('Priority3'))
            obj.Priority = 'P3';
        }
        
         if(trigger.isInsert && trigger.isBefore){
    
      for (Case obj: trigger.new) {
        if(obj.Subject.Contains('Priority4'))
            obj.Priority = 'P4';
          }
         }
        }
       }
      }     
}