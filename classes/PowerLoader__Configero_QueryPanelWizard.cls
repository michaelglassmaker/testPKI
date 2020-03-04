/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class Configero_QueryPanelWizard {
    global List<System.SelectOption> objectList {
        get;
    }
    global List<List<System.SelectOption>> objectListMulti {
        get;
    }
    global Configero_QueryPanelWizard(ApexPages.StandardSetController c) {

    }
    @RemoteAction
    global static Boolean checkQueryPanelExists(String name) {
        return null;
    }
    @RemoteAction
    global static Id createQueryPanel(String name, Integer numPerRow, List<Map<String,String>> params) {
        return null;
    }
    @RemoteAction
    global static List<Map<String,String>> getFieldsForObject(String objectAPIName) {
        return null;
    }
}
