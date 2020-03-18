public class CaseTriggerHandler 
{
    //Static variables
    public static Set<Id> caseId = new Set<Id>();
    public static Map<Id, List<case>> mapIdVsCase = new Map<Id, List<case>>();
    
    public static void beforeUpdate (List<Case> updatedCases)
    {
        Integer intSize = updatedCases.size();
        System.debug('int Size'+intSize);
        for(Integer i = 0 ; i< intSize; i++)
        {
             if(mapIdVsCase.containsKey(updatedCases[i].Id))
             {
                 system.debug('mapIdVs Case'+ mapIdVsCase);
                 for(Case obj : mapIdVsCase.get(updatedCases[i].Id))
                 {
                     updatedCases[i].Original_Case_Open__c = updatedCases[i].CreatedDate;
                     if(updatedCases[i].CreatedDate > obj.CreatedDate)
                     {
                         updatedCases[i].Original_Case_Open__c =  obj.CreatedDate;
                     }
                 }
                 system.debug('updates Cases :'+updatedCases[i]);
             }
        }
    }
    
    public static void beforeDelete(List<Case> deletedCases)
    {
        //Append Description to static variable deletedDescriptions
        for(Case l : deletedCases){
            System.debug('Case In beforeDelete : ' + l);
            if(!mapIdVsCase.containsKey(l.ParentId)){
                mapIdVsCase.put(l.ParentId, new List<case> {l});
             }
            else
            {
               List<case> lstcase = mapIdVsCase.get(l.ParentId);
               lstcase.add(l);
               mapIdVsCase.put(l.ParentId, lstcase); 
            }  
        }
    } 
}