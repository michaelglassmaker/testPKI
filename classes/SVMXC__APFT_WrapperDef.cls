/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class APFT_WrapperDef {
    global APFT_WrapperDef() {

    }
global class APFT_FilterInfo implements System.Comparable {
    webService Boolean androidPhoneEnabled {
        get;
        set;
    }
    webService Boolean androidTabletEnabled {
        get;
        set;
    }
    webService String description {
        get;
        set;
    }
    @WebService
    webService List<SVMXC.APFT_WrapperDef.APFT_FilterInfo> filterInfoList;
    webService Boolean iPadEnabled {
        get;
        set;
    }
    webService Boolean iPhoneEnabled {
        get;
        set;
    }
    webService String name {
        get;
        set;
    }
    webService Boolean onlineEnabled {
        get;
        set;
    }
    webService String processId {
        get;
        set;
    }
    webService Boolean windowsEnabled {
        get;
        set;
    }
    global APFT_FilterInfo() {

    }
    global Integer compareTo(Object compareTo) {
        return null;
    }
}
global class APFT_Request {
    @WebService
    webService List<SVMXC.APFT_WrapperDef.APFT_FilterInfo> filterInfoList;
    webService Datetime lastModifiedOn {
        get;
        set;
    }
    webService String recordTypeName {
        get;
        set;
    }
    webService String sourceObjectName {
        get;
        set;
    }
    global APFT_Request() {

    }
}
global class APFT_Response {
    @WebService
    webService List<SVMXC.APFT_WrapperDef.APFT_FilterInfo> filterInfoList;
    webService Datetime lastModifiedOn {
        get;
        set;
    }
    webService String message {
        get;
        set;
    }
    @WebService
    webService List<SVMXC.APFT_WrapperDef.ObjectInfo> objectInfoList;
    webService Boolean success {
        get;
        set;
    }
    webService Boolean warning {
        get;
        set;
    }
    global APFT_Response() {

    }
}
global class ObjectInfo implements System.Comparable {
    global Integer compareTo(Object compareTo) {
        return null;
    }
}
}
