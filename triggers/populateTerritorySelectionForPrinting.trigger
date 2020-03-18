trigger populateTerritorySelectionForPrinting on Territory_Selection__c (before insert, before update) {

   //Construct a collection for Territory Selection Records from the Trigger 
    Territory_Selection__c[] TerritorySelectionList;
    TerritorySelectionList = Trigger.new;

    String TerritorySelectionListInLines;
   //Process All Territory Selection Records 
    for (Territory_Selection__c territorySelection : TerritorySelectionList) {

        // America Countries - breaking for Printing in Agreements
        territorySelection.Americas_Countries_Print_1__c = '';
        territorySelection.Americas_Countries_Print_2__c = '';
        territorySelection.Americas_Countries_Print_3__c = '';

        Utility_PKI_Apttus.TerritoriesBatches americaBatches = new Utility_PKI_Apttus.TerritoriesBatches();

        americaBatches = Utility_PKI_Apttus.splitTerritories(territorySelection.Americas_Countries__c);

        territorySelection.Americas_Countries_Print_1__c = americaBatches.batch1;
        territorySelection.Americas_Countries_Print_2__c = americaBatches.batch2;
        territorySelection.Americas_Countries_Print_3__c = americaBatches.batch3;
        
        // Europe Countries - breaking for Printing in Agreements
        territorySelection.Europe_Countries_Print_1__c = '';
        territorySelection.Europe_Countries_Print_2__c = '';
        territorySelection.Europe_Countries_Print_3__c = '';

        Utility_PKI_Apttus.TerritoriesBatches europeBatches = new Utility_PKI_Apttus.TerritoriesBatches();

        //europeBatches = Utility_PKI_Apttus.splitTerritories(territorySelection.Europe_Countries_1__c);

        //territorySelection.Europe_Countries_Print_1__c = europeBatches.batch1;
        //territorySelection.Europe_Countries_Print_2__c = europeBatches.batch2;
        //territorySelection.Europe_Countries_Print_3__c = europeBatches.batch3;
        String europeanCountries = '';
        if(territorySelection.Europe_Countries_1__c != NULL && territorySelection.Europe_Countries_2__c == NULL)
            europeanCountries +=  territorySelection.Europe_Countries_1__c;
        else if(territorySelection.Europe_Countries_1__c == NULL &&  territorySelection.Europe_Countries_2__c != NULL)
            europeanCountries +=  territorySelection.Europe_Countries_2__c;
        else if(territorySelection.Europe_Countries_1__c != NULL &&  territorySelection.Europe_Countries_2__c != NULL)
            europeanCountries +=  territorySelection.Europe_Countries_1__c + ';'+ territorySelection.Europe_Countries_2__c;
        else
            europeanCountries = '';
        
        
        europeBatches = Utility_PKI_Apttus.splitTerritories(europeanCountries);

        territorySelection.Europe_Countries_Print_1__c += europeBatches.batch1;
        territorySelection.Europe_Countries_Print_2__c += europeBatches.batch2;
        territorySelection.Europe_Countries_Print_3__c += europeBatches.batch3;
        
       // Asia Countries - breaking for Printing in Agreements
        territorySelection.Asia_Countries_Print_1__c = '';
        territorySelection.Asia_Countries_Print_2__c = '';
        territorySelection.Asia_Countries_Print_3__c = '';

        Utility_PKI_Apttus.TerritoriesBatches asiaBatches = new Utility_PKI_Apttus.TerritoriesBatches();

        asiaBatches = Utility_PKI_Apttus.splitTerritories(territorySelection.Asia_Countries__c);

        territorySelection.Asia_Countries_Print_1__c = asiaBatches.batch1;
        territorySelection.Asia_Countries_Print_2__c = asiaBatches.batch2;
        territorySelection.Asia_Countries_Print_3__c = asiaBatches.batch3;

    }

}