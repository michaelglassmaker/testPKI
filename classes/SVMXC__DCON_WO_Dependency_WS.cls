/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class DCON_WO_Dependency_WS {
    webService static SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Response DCON_WO_Dependency_Check_WS(SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request req) {
        return null;
    }
    webService static List<SVMXC.DCON_WO_Dependency_WS.Dependency_Details> DCON_WO_Get_Dependency_Details_WS(SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request req) {
        return null;
    }
global class Dependency_Details {
    webService String breakTime {
        get;
        set;
    }
    webService String dependencyGroup {
        get;
        set;
    }
    webService String dependencyGroupName {
        get;
        set;
    }
    webService String driveTimeAfter {
        get;
        set;
    }
    webService String driveTimeBefore {
        get;
        set;
    }
    webService Boolean isPrimaryWorkOrder {
        get;
        set;
    }
    webService String maximumDeviation {
        get;
        set;
    }
    webService String maximumDeviationUnits {
        get;
        set;
    }
    webService String minimumDeviation {
        get;
        set;
    }
    webService String minimumDeviationUnits {
        get;
        set;
    }
    webService String overHeadTimeAfter {
        get;
        set;
    }
    webService String overHeadTimeBefore {
        get;
        set;
    }
    webService String primaryWOName {
        get;
        set;
    }
    webService String primaryWorkOrder {
        get;
        set;
    }
    webService String primaryWorkOrderName {
        get;
        set;
    }
    webService String resourceDependency {
        get;
        set;
    }
    webService String scheduledStartTime {
        get;
        set;
    }
    webService String secondaryWorkOrder {
        get;
        set;
    }
    webService String secondaryWorkOrderName {
        get;
        set;
    }
    webService String serviceDuration {
        get;
        set;
    }
    webService String technicianId {
        get;
        set;
    }
    webService String technicianName {
        get;
        set;
    }
    webService String timeDependency {
        get;
        set;
    }
    webService String woId {
        get;
        set;
    }
}
global class EventErrorMessage {
    webService String errorMessage {
        get;
        set;
    }
    webService String eventId {
        get;
        set;
    }
    webService String typeOfResourceDependency {
        get;
        set;
    }
    webService String typeOfTimeDependency {
        get;
        set;
    }
    webService String woId {
        get;
        set;
    }
}
global class Preferrable_Workorder_Timings {
    webService String dependencyGroupName {
        get;
        set;
    }
    webService String maxEndtime {
        get;
        set;
    }
    webService String maxStarttime {
        get;
        set;
    }
    webService String minEndtime {
        get;
        set;
    }
    webService String minStarttime {
        get;
        set;
    }
    webService String woId {
        get;
        set;
    }
}
global class Workorder_Dependency_Request {
    @WebService
    webService List<String> listWOIds;
    @WebService
    webService List<Event> lstSFEvent;
    @WebService
    webService List<SVMXC__SVMX_Event__c> lstSVMXEvent;
    webService String timeZone {
        get;
        set;
    }
    webService String userId {
        get;
        set;
    }
}
global class Workorder_Dependency_Response {
    @WebService
    webService List<SVMXC.DCON_WO_Dependency_WS.EventErrorMessage> eventDetails;
    @WebService
    webService List<SVMXC.DCON_WO_Dependency_WS.Preferrable_Workorder_Timings> woDetails;
}
}
