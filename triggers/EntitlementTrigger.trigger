/*
** Trigger:  EntitlementTrigger
** SObject:  Entitlement
** Created by OpFocus on 05/06/2012
** Description: The trigger flags Entitlement Updated in Asset to fire Asset Trigger to update Contract Status, 
**              Active Contract End Date and Active Contract Type
*/
trigger EntitlementTrigger on Entitlement (after insert, after update, after delete, after undelete) {
	if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete)) {
		// Instantiate Assets to update from the change on Entitlement Status
		Map<Id, Asset> mapAssets = new Map<Id, Asset>();
		
		for (Entitlement newEnt : Trigger.new) {
			if (newEnt.AssetId != null) {
				Asset a = new Asset(Id = newEnt.AssetId);
				// Set Entitlement Update to true for the Asset.
				a.Entitlement_Updated__c = true;
				mapAssets.put(a.Id, a);
			}
		}
		// Update Assets
		if(mapAssets.size()>0) update mapAssets.values();
	}

	if (trigger.isAfter && trigger.isDelete){
		// Instantiate Assets to update from the change on Entitlement Status
		Map<Id, Asset> mapAssets = new Map<Id, Asset>();
		
		for (Entitlement oldEnt : Trigger.old) {
			if (oldEnt.AssetId != null) {
				Asset a = new Asset(Id = oldEnt.AssetId);
				// Set Entitlement Update to true for the Asset.
				a.Entitlement_Updated__c = true;
				mapAssets.put(a.Id, a);
			}
		}
		// Update Assets
		if(mapAssets.size()>0) update mapAssets.values();
		
	}
}