/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class DCON_AES_Event_WS {
    webService static SVMXC.DCON_AES_Event_WS.AES_Response DCON_AES_Create_Events_WS(SVMXC.DCON_AES_Event_WS.AES_Request req) {
        return null;
    }
global class AES_Request {
    webService Integer eventMinDuration {
        get;
        set;
    }
    webService Boolean isCalculateEndTime {
        get;
        set;
    }
    webService Boolean IsdeleteEvents {
        get;
        set;
    }
    webService Boolean isMachineWorkingHrsEnabled {
        get;
        set;
    }
    webService Boolean isOverlappingEnabled {
        get;
        set;
    }
    webService Boolean isTechWorkingHrsEnabled {
        get;
        set;
    }
    webService Boolean IsUnAssignWorkOrder {
        get;
        set;
    }
    @WebService
    webService List<Event> lstEvent;
    @WebService
    webService List<SVMXC.DCON_Configuration_WS.SVMX_StringMap> lstKeyValue;
    @WebService
    webService List<String> lsttechId;
    webService String timeZone {
        get;
        set;
    }
    webService String UserId {
        get;
        set;
    }
}
global class AES_Response {
    webService String deletedEvents {
        get;
        set;
    }
    webService String endDatetime {
        get;
        set;
    }
    webService Integer eventsCounter {
        get;
        set;
    }
    webService List<String> lstAESEvent {
        get;
        set;
    }
    webService Integer remainderServiceDuration {
        get;
        set;
    }
    webService String startDatetime {
        get;
        set;
    }
}
global class StartEndTime {
    webService Datetime endTime {
        get;
        set;
    }
    webService Datetime startTime {
        get;
        set;
    }
}
}
