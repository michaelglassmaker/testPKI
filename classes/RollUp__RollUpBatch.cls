/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class RollUpBatch implements Database.Batchable<SObject>, Database.Stateful {
    global Boolean isMultiCurrencyOrg;
    global String lastError;
    global Boolean loadSuccess;
    global Integer recordsErrored;
    global Integer recordsProcessed;
    global Integer recordsUpdated;
    global RollUp__RollUp__c rollUpRec;
    global Schema.DisplayType sourceType;
    global Schema.DisplayType targetType;
    global RollUpBatch(Id rollUpId) {

    }
    global void execute(Database.BatchableContext BC, List<SObject> scope) {

    }
    global void finish(Database.BatchableContext BC) {

    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return null;
    }
}
