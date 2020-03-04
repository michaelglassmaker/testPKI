/*Change Tag - <T01>
 * Change made by - Lister Technologies 
 * Change made on -  04/24/2017
 * Purpose - To update the product family details on change of product line through a custom setting
 * 
 */
public class HandlerNewProductCreation
{
   //start of <T01>
   //method to update the product family and product family numbered by using the custom setting product line mapping
   //before insert and update of a product record
   public void updateProductFamilyDetails(List<Product2> newProducts,List<Product2> oldProducts,Map<id,Product2> oldMap,boolean isInsert,boolean isUpdate){
        
      
        Map<String,Product_Line_Mapping__c> ProdLineProdFamilyMap =Product_Line_Mapping__c.getall();
        if(isInsert){
            for(Product2 prod:newProducts){
                if(prod.product_line__c!=null) {
                    system.debug('products product line item'+prod.product_line__c);
                    if(ProdLineProdFamilyMap.keySet().contains(prod.product_line__c)){
                        system.debug('inside prod family map condition');
                        prod.Product_Family_Numbered__c=ProdLineProdFamilyMap.get(prod.product_line__c).Product_Family_Numbered__c;
                        prod.Family=ProdLineProdFamilyMap.get(prod.product_line__c).Product_Family__c;
                        system.debug('product after assignment' +prod);
                        
                    } 
                }
            }
        }
        else if(isUpdate){
            for(Product2 prod:newProducts){
                if((prod.product_line__c!=oldMap.get(prod.id).product_line__c)){
                    if(ProdLineProdFamilyMap.keySet().contains(prod.product_line__c)){
                        prod.Product_Family_Numbered__c=ProdLineProdFamilyMap.get(prod.product_line__c).Product_Family_Numbered__c;
                        prod.Family=ProdLineProdFamilyMap.get(prod.product_line__c).Product_Family__c;
                    }
                }
            }
        }        
       
    }
    //end of <T01>
    @future
    public static void createPBEntry(List<Id> listOfProdIds)
    {   
        try
        {
            system.debug('inside createPBentry');
        Map<Id,Product2> newMap =  new Map<Id,Product2>();
        for(Product2 iterProd : [select Id,PartNum__c from Product2 where Id in: listOfProdIds]){
            newMap.put(iterProd.Id,iterProd);
        }
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        List<PricebookEntry> standardPriceBookentries = new List<PricebookEntry>();
        List<currencytype> listcurr = [SELECT conversionrate, isocode FROM currencytype];
        for(ID iterable : newMap.keyset())
        {
            for(currencytype curr : listcurr)
            {
                PricebookEntry pbe = new PricebookEntry(Pricebook2Id = standardPB.Id,currencyISOCode=curr.isocode, Product2Id = iterable, UnitPrice = 1, IsActive = true ,UseStandardPrice = false);
                if(newMap.get(iterable) != null)
                {
                    pbe.Pricebook_entry_ID__c = newMap.get(iterable).PartNum__c + '-' + 'StandardPriceBook' +'-'+ curr.isocode;
                }
                system.debug('pbe.Pricebook_entry_ID__c' + pbe.Pricebook_entry_ID__c);
                system.debug('pbe.Product2Id' + pbe.Product2Id);
                standardPriceBookentries.add(pbe);
            }
            
        }
       
            database.insert(standardPriceBookentries,false) ;
        }
        catch(Exception e)
        {
            system.debug('Exception' + e.getmessage());    
        }    
    }
    
}