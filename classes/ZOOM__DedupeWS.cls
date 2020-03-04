/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class DedupeWS {
    global DedupeWS() {

    }
    webService static List<List<SObject>> runAccountQuery(List<ZOOM.DedupeWS.CompanyItem> Companies) {
        return null;
    }
    webService static List<List<SObject>> runContactQuery(List<ZOOM.DedupeWS.PersonItem> People) {
        return null;
    }
    webService static List<List<SObject>> runLeadQuery(List<ZOOM.DedupeWS.PersonItem> People) {
        return null;
    }
global class CompanyItem {
    @WebService
    webService String BillingPostalCode;
    @WebService
    webService String ID;
    @WebService
    webService String Name;
    @WebService
    webService String Phone;
    @WebService
    webService String Website;
    global CompanyItem() {

    }
}
global class PersonItem {
    @WebService
    webService String ID;
    @WebService
    webService ZOOM.DedupeWS.PersonName Name;
    global PersonItem() {

    }
}
global class PersonName {
    @WebService
    webService String First;
    @WebService
    webService String Last;
    global PersonName() {

    }
}
global class Results {
    @WebService
    webService List<SObject> Items;
    global Results() {

    }
}
}
