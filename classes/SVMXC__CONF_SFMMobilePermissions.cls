/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class CONF_SFMMobilePermissions {
    global CONF_SFMMobilePermissions() {

    }
    @RemoteAction
    global static SVMXC.CONF_SFMMobilePermissions.Response Save(String requestString) {
        return null;
    }
    @RemoteAction
    global static SVMXC.CONF_SFMMobilePermissions.Response addAllChecklist(String requestString) {
        return null;
    }
    @RemoteAction
    global static SVMXC.CONF_SFMMobilePermissions.Response onChangeObject(String requestString) {
        return null;
    }
    @RemoteAction
    global static SVMXC.CONF_SFMMobilePermissions.Response onChangeProcessType(String requestString) {
        return null;
    }
    @RemoteAction
    global static SVMXC.CONF_SFMMobilePermissions.Response onChangeProfile(String requestString) {
        return null;
    }
    @RemoteAction
    global static SVMXC.CONF_SFMMobilePermissions.Response onPageLoad() {
        return null;
    }
    @RemoteAction
    global static SVMXC.CONF_SFMMobilePermissions.Response onSearchOrSort(String requestString) {
        return null;
    }
global class ProcessDetails {
    @WebService
    webService String field;
    @WebService
    webService String id;
    @WebService
    webService String name;
    @WebService
    webService List<SVMXC.CONF_SFMMobilePermissions.ProcessDetails> processDetails;
    @WebService
    webService String processID;
    @WebService
    webService String processType;
    global ProcessDetails() {

    }
    global ProcessDetails(String id, String name, String processID, String processType, String field) {

    }
}
global class Request {
    @WebService
    webService String name;
    @WebService
    webService String objectName;
    @WebService
    webService List<SVMXC.CONF_SFMMobilePermissions.ProcessDetails> processDetails;
    @WebService
    webService String processType;
    @WebService
    webService String searchText;
    @WebService
    webService String sortBy;
    @WebService
    webService String svmxProfile;
    global Request() {

    }
}
global class Response {
    @WebService
    webService List<String> items;
    @WebService
    webService String objectName;
    @WebService
    webService String page;
    @WebService
    webService List<SVMXC.CONF_SFMMobilePermissions.ProcessDetails> processDetails;
    @WebService
    webService String svmxProfile;
    global Response() {

    }
}
}
