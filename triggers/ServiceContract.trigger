/*
** Trigger:  ServiceContract
** SObject:  ServiceContract
** Created by OpFocus on 05/08/2012
** Description: Clone Contract Line Items for Service Contracts when a new Service Contract is created from Clone with Line Items button
*/
trigger ServiceContract on ServiceContract (after insert) {
	if (Trigger.isAfter && Trigger.isInsert) {
		
		List<ContractLineItem> lstClisToCreate = new List<ContractLineItem>();
		Set<Id> setServiceContractIds = new Set<Id>();
		
		// Create a set of Original Service Contracts
		for (ServiceContract sc : Trigger.new) {
			if (sc.Clone_From_Id__c != null && sc.Clone_Line_Items__c) setServiceContractIds.add(sc.Clone_From_Id__c);
		}
		
		// Find the original Service Contract that the clone came from
		List<ContractLineItem> lstClis = 
			[select AssetId, StartDate, EndDate, Description, Quantity, 
				UnitPrice, Discount, System_ID__c, PricebookEntryId 
			 from   ContractLineItem
			 where  ServiceContractId in :setServiceContractIds];
			 
		// Create new Contract Line Items for the clone Service Contract with the same products as the original
		for (ServiceContract sc : Trigger.new) {
			for (ContractLineItem cli : lstClis) {
				if (sc.Clone_From_Id__c != null && sc.Clone_Line_Items__c) {
					lstClisToCreate.add(new ContractLineItem (
					  ServiceContractId = sc.Id,
					  AssetId           = cli.AssetId,
					  StartDate         = cli.StartDate,
					  EndDate           = cli.EndDate,
					  Quantity          = cli.Quantity,
					  UnitPrice         = cli.UnitPrice,
					  Discount          = cli.Discount,
					  System_ID__c      = cli.System_ID__c,
					  PricebookEntryId  = cli.PricebookEntryId,
					  Description 	    = cli.Description));
				}
			}
			break;
		}
		if (lstClisToCreate.size() > 0) insert lstClisToCreate;						
	}
}