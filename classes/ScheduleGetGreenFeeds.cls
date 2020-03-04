global class ScheduleGetGreenFeeds implements Schedulable{  


    global void execute(SchedulableContext SC) {    
        GetGreenFeeds newPosts = new GetGreenFeeds() ;    
 
        Database.executeBatch(newPosts,1);  
    }    
}