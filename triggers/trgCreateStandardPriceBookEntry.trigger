/*Change Tag - <T01>
 * Change made by - Lister Technologies 
 * Change made on -  04/24/2017
 * Purpose - To update the product family details on change of product line through a custom setting before insert and update
 * 
 */
trigger trgCreateStandardPriceBookEntry on Product2 (after Insert,after update,before insert,before update) {
    
    //start of <T01>
    if(Trigger.isBefore){
         HandlerNewProductCreation handler=new  HandlerNewProductCreation();
         handler.updateProductFamilyDetails(Trigger.new,Trigger.old,Trigger.oldMap,Trigger.isInsert,Trigger.isUpdate);
    }
    // end of <T01>
   
    //HandlerNewProductCreation handler1 = new HandlerNewProductCreation(Trigger.newMap);
    if(Trigger.isAfter)
    {
        List<Id> listOfProdIds = new List<Id>();
        for(Product2 iterProd : Trigger.New){
            listOfProdIds.add(iterProd.id);
        }
        HandlerNewProductCreation.createPBEntry(listOfProdIds);
    }
   
    
   /* if(Trigger.isUpdate && Trigger.isAfter)
    {
        handler1.createPBEntry();
    }
    */
    
    

}