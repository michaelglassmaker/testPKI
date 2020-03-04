public with sharing class GreenFeedsSetupController {  
    public Boolean isTest = false; 
   
    public GreenFeedsSetupController() {
    }
    
    public void init(){
        //Create the green tips group
        CollaborationGroup cg1 = new CollaborationGroup();        
        cg1.name='Green Tips';           
        cg1.CollaborationType='public';
              
        //Create the green news group     
        CollaborationGroup cg2 = new CollaborationGroup();        
        cg2.name='Green News';           
        cg2.CollaborationType='public';
                     
        if (!isTest){
            insert cg1;
            insert cg2;  
        }     
              
        //Create the 2 Feeds objects referencing 2 rss feed linked to the green tip group        
        Green_feed__c gf1 = new Green_feed__c();        
        gf1.name='The Daily Green';        
        gf1.url__c='http://www.thedailygreen.com/living-green/rss/';        
        gf1.Groupid__c=cg1.id;        
              
        Green_feed__c gf2 = new Green_feed__c();        
        gf2.name='Lifetips';        
        gf2.url__c='http://greenliving.lifetips.com/rss/TipOfTheDay.xml';        
        gf2.Groupid__c=cg1.id;        
               
        //Create 2 Feeds objects referencing 2 rss feed linked to the green news group        
        Green_feed__c gf3 = new Green_feed__c();        
        gf3.name='Environmental Leader';        
        gf3.url__c='http://feeds.feedburner.com/EnvironmentalLeader/';        
        gf3.Groupid__c=cg2.id;
                               
        Green_feed__c gf4 = new Green_feed__c();        
        gf4.name='Greenbiz';        
        gf4.url__c='http://feeds.feedburner.com/greenbiz/energy-climate';        
        gf4.Groupid__c=cg2.id;        
        
        if (!isTest){
            insert gf1;
            insert gf2;
            insert gf3;
            insert gf4;            
              
        }            
    }
    
    
    public void getGreenFeeds(){
         GetGreenFeeds newPosts = new GetGreenFeeds();
         Database.executeBatch(newPosts,1);          
    }
}