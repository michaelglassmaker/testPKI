public class InteractionAssignment{

public static void InteractionAssignmenthelper(list<SFDC_Interaction__c> SIList){

string region,pl,sai;

for(SFDC_Interaction__c si:SIList){
region=si.Global_Region__c;
pl=si.Product_Line__c;
sai=si.Solution_Area_of_Interest__c;

}
string strQuery='select id,Product_Line__c,Country_Region__c,SAI__c,User__c,User__r.ID,OwnerId from Interaction_Assignment__c where ';
    system.debug('---inputs '+region+pl+sai);
if(!string.isblank(region)){
strQuery=strQuery+ ' Country_Region__c=:region '; 
}
if(!string.isblank(pl)){
strQuery=strQuery+'AND Product_Line__c=:pl ';
}
if(!string.isblank(sai)){
strQuery=strQuery+'AND SAI__c=:sai ';
}
strQuery=strQuery+' limit 10';
    system.debug('---strQuery '+strQuery);
Interaction_Assignment__c IA=Database.query(strQuery);
system.debug('---IA '+IA); 
if(IA!=null){
for(SFDC_Interaction__c SI:SIList){
SI.OwnerId=IA.OwnerId;
}
}
}
}