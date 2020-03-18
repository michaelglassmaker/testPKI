/***********************************************************
*Created By: Lister technologies
*Purpose: To get count of contacts under Accounts. 
************************************************************/
trigger UpdateNoOfContacts on Contact (after delete, after insert, after undelete, after update) {
    
    Contact[] cons;
    //Construct a collection for Contact records from the Trigger 
    if (Trigger.isDelete)
        cons = Trigger.old;
    else
        cons = Trigger.new;
        
    // Get list of account Ids from the Contact collection
    Set<ID> acctIds = new Set<ID>();
    for (Contact con : cons) {
        if(con.AccountId!=NULL)
           acctIds.add(con.AccountId);
    }
    
   
   //Construct a map of Contact Id to Contact Record based on the Account Ids collected.
    Map<ID, Contact> contactsForAccounts = new Map<ID, Contact>([select Id
                                                            ,AccountId
                                                            from Contact
                                                            where AccountId in :acctIds]);
    //Construct a map of Account Id to Account Record based on the Account Ids collected.
    Map<ID, Account> acctsToUpdate = new Map<ID, Account>([select Id
                                                                 ,No_of_Contacts_INF__c
                                                                  from Account
                                                                  where Id in :acctIds]);
     
    //Logic to check whether a Contact record falls under an Account(matching with Account Id) and updating the number of Contacts in an Account                                                          
    for (Account acct : acctsToUpdate.values()) {
        Set<ID> conIds = new Set<ID>();
        for (Contact con : contactsForAccounts.values()) {
            if (con.AccountId == acct.Id)
                conIds.add(con.Id);
        }
        if (acct.No_of_Contacts_INF__c != conIds.size())
            acct.No_of_Contacts_INF__c = conIds.size();
    }
    
    //DML operation to update Account records
    update acctsToUpdate.values();

}