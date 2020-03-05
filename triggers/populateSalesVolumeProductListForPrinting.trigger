trigger populateSalesVolumeProductListForPrinting on Sales_Volume_Requirement__c (before insert, before update) {

   //Construct a collection for Sales Volume Product List Records from the Trigger 
    Sales_Volume_Requirement__c[] SalesVolumeRequirementList;
    SalesVolumeRequirementList = Trigger.new;

   //Process All Agreements 
    for (Sales_Volume_Requirement__c SalesVolumeRequirement : SalesVolumeRequirementList) {
        SalesVolumeRequirement.Apts_Product_Line_Print__c = '';
        if (SalesVolumeRequirement.Apts_Product_Line__c != null) {
            SalesVolumeRequirement.Apts_Product_Line_Print__c = SalesVolumeRequirement.Apts_Product_Line__c.replace(';', '\n');
        }
    }
}