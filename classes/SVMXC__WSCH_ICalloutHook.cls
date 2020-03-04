/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global interface WSCH_ICalloutHook {
    void afterCall(SVMXC.WSCH_IResponse param0, List<SObject> param1, SVMXC.WSCH_Status param2);
    void beforeCall(SVMXC.WSCH_IRequest param0, List<SObject> param1, SVMXC.WSCH_Status param2);
    void configure();
}
