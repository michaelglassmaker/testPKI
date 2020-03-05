trigger SMAX_PS_GeoTechnician on SMAX_PS_Geography_Technician__c (after insert, after delete) {
	if (Trigger.isAfter && Trigger.isInsert)
	{
		List<SMAX_PS_Geography_Technician__c> geoTechList = (List<SMAX_PS_Geography_Technician__c>)Trigger.new;
		SMAX_PS_TechnicianManager.onTechnicianGeographies(geoTechList);
	}
	if (Trigger.isAfter && Trigger.isDelete)
	{
		List<SMAX_PS_Geography_Technician__c> geoTechList = (List<SMAX_PS_Geography_Technician__c>)Trigger.old;
		SMAX_PS_TechnicianManager.onTechnicianGeographies(geoTechList);
	}
}