/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class EventbriteImportController {
    @RemoteAction
    global static gweb.EventbriteImportController.CreateCampaignResult createCampaign(String campaignName, String recordTypeId, String campaignType, Date startDate, Date endDate, String status, String parentCampaignId, String description) {
        return null;
    }
    @RemoteAction
    global static List<Campaign> getCampaignList(Integer maxRecords) {
        return null;
    }
    @RemoteAction
    global static List<String> getCampaignMemberStatuses(String sCampaignId) {
        return null;
    }
    @RemoteAction
    global static List<gweb.EventbriteImportController.ImportAttendeeResult> importAttendees(String eventJson, List<String> attendeeJson, String campaignId, String contactDescription, String Username, String Password, String apiUserKey, Integer OptionForLeadsOrContacts, Boolean UseExistingContact, Boolean OverwriteContactDetail, String LeadSource, Boolean CreateAccounts, Integer OptionForCampaign, String CampaignMbrStatus, String OppContactRole, String OppRecordTypeId, String OppStage, Boolean CreateFreeOpps) {
        return null;
    }
global class CreateCampaignResult {
    global CreateCampaignResult() {

    }
}
global class ImportAttendeeResult {
    global ImportAttendeeResult() {

    }
}
}
