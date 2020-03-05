/*
** Trigger:  Asset
** SObject:  Asset
** Created by OpFocus on 05/10/2012
** Description: The trigger updates Contract Status, Active Contract End Date and Active Contract Type when there a change in Entitlement Status
*/
trigger Asset on Asset (before update) {
	
	if (Trigger.isBefore && Trigger.isUpdate) {
		
		// Figure out which Assets we need to calculate a new Contract Status, Active Contract End Date and Active Contract Type for
		List<Id> lstAssetsToUpdate = new List<Id>();
		for(Asset a : Trigger.new) {
			if(a.Entitlement_Updated__c == true) lstAssetsToUpdate.add(a.Id);
		}
		
		// Create a collection of Assets and Active Entitlements
		Map<Id, Asset> assetWithActiveEntitlements = new Map<Id, Asset>(
			[select id, Active_Contract_End_Date__c, Active_Contract_Type__c, Contract_Status__c,
		                                           (select Id, Type, Status, EndDate
			                                        from   Entitlements 
			                                        where  AssetId IN :Trigger.newMap.keySet()
			                                        and    Status = 'Active'
			                                        order by EndDate asc)
			                                       from   Asset where id in :lstAssetsToUpdate]);
			                                       
		Map<Id, Asset> assetWithInactiveEntitlements = new Map<Id, Asset>(
		[select id, Active_Contract_End_Date__c, Active_Contract_Type__c, Contract_Status__c,
		                                             (select Id, Type, Status, EndDate
		                                              from   Entitlements 
		                                              where  AssetId IN :Trigger.newMap.keySet()
		                                              and    Status != 'Active'
		                                              order by EndDate desc)
		                                             from   Asset where id in :lstAssetsToUpdate]);
			                                 
		for (Asset a : Trigger.new) {
			// See if we need to update the Asset's Contract Status, Active Contract End Date and Active Contract Type
			if (a.Entitlement_Updated__c == true) {
				a.Entitlement_Updated__c = false;
						
				if (assetWithActiveEntitlements.containsKey(a.Id) && assetWithActiveEntitlements.get(a.Id).Entitlements.size()>0) {
					Asset assetFromDb = assetWithActiveEntitlements.get(a.Id);
					// Check to see if related Entitlements have an Active Status
					// Set Asset Contract Status, Active Contract End Date and Active Contract Type to Entitlement
					// Status, Type and End Date
					a.Active_Contract_End_Date__c = assetFromDb.Entitlements[0].EndDate;
					a.Active_Contract_Type__c     = assetFromDb.Entitlements[0].Type;
					a.Contract_Status__c          = assetFromDb.Entitlements[0].Status;
				}
				else if (assetWithInactiveEntitlements.containsKey(a.Id) && assetWithInactiveEntitlements.get(a.Id).Entitlements.size()>0) {
					Asset assetFromDb = assetWithInactiveEntitlements.get(a.Id);

					// For related Entitlements with Inactive Status
					// Set Asset Active Contract End Date and Active Contract Type to null
					// And set Asset Contract Status to Entitlement Status
					a.Active_Contract_End_Date__c = null;
					a.Active_Contract_Type__c     = null;
					a.Contract_Status__c          = assetFromDb.Entitlements[0].Status;											
				}
				else {
					// Didn't find any Entitlement Active or Inactive for the asset					
					a.Active_Contract_End_Date__c = null;
					a.Active_Contract_Type__c     = null;
					a.Contract_Status__c          = null;					
				}		
			}
		}
	}
}