global class GetGreenFeeds implements Database.Batchable<sObject>, Database.AllowsCallouts{        

public Boolean isTest = false;    
public String testReturnXML = '';    
public String  soql = '';    
private boolean postRead = false;    
private final Integer maxPostSize = 500;        

global  database.querylocator start(Database.BatchableContext bc){            
    if (soql == ''){                
        soql = 'select Id, Name, url__c,groupid__c from Green_feed__c where active__c = true order by name';            
    }             
    return Database.getQueryLocator(soql);        
}                               
        
global void execute(Database.BatchableContext bc, sObject[] objects){
            Green_feed__c rss;                                  
            for(SObject so : objects){
                rss = (Green_feed__c) so;
                boolean postRead = false;              
                getfeed(rss.url__c, rss.Id,rss.groupid__c);            
            }
                }

    public void getFeed(string url, string parentId, string groupId){
        string xml = '';
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        if(!isTest){
            HttpResponse res = h.send(req);
            xml = res.getBody();
        }else{
            xml = testReturnXML;
        }
        XmlStreamReader xsr = new XmlStreamReader(xml);
        while (xsr.hasNext() && !postRead){
            if (xsr.getEventType() ==XmlTag.START_ELEMENT){
                if(xsr.getLocalName() == 'item'){
                    parseItem(xsr, parentId,groupId);
                }
            }
            xsr.next();
        }        
    }

    private void parseItem(XmlStreamReader xsr, string parentId, string groupId){
        string currentElement = '';
        string currentTitle = '';
        string currentLinkUrl = '';
        string currentDescription = '';
        while (xsr.hasNext()){                
            if (xsr.getLocalName() == 'item' && xsr.getEventType() == XmlTag.END_ELEMENT){
                currentDescription=removeHTML(currentDescription);
                if (currentDescription.length()>maxPostSize){
                    currentDescription=currentDescription.substring(0,maxPostSize)+'...View more @';
                }
                String queryTitle = currentTitle;
                queryTitle =queryTitle.substring(0,currentTitle.length()-10) + '%';
                // Check is this post already exists in Chatter
                List<NewsFeed> lF= [select id from NewsFeed where FeedPost.Title like :queryTitle]; 
                    if (lF.size()==0){
                        FeedPost fpost = new FeedPost();
                        fpost.Type = 'TextPost';
                        fpost.ParentId=groupId;
                        fpost.Body = currentTitle+currentDescription+currentLinkUrl;
                        fpost.Title=currentTitle;
                        if (!isTest){
                            insert fpost;
                        }
                    }
                postRead=true;
                break;                
            } else if (xsr.getEventType() == XmlTag.START_ELEMENT){
                currentElement = xsr.getLocalName();
            } else if (xsr.getEventType() == XmlTag.CHARACTERS ) {
                string temp = xsr.getText();
                if (currentElement == 'title'){
                    currentTitle  = currentTitle + temp;
                }else if(currentElement == 'link'){
                    currentLinkUrl  = currentLinkUrl + temp;
                }else if(currentElement == 'description'){
                    currentDescription = currentDescription + temp;
                }
            }
            xsr.next();
        }
    }


    private String removeHTML(String htmlString){
        // thanks to community user Sureka (http://community.salesforce.com/t5/user/viewprofilepage/user-id/34293) for this snippet!
        try{
            String noHTMLString = htmlString;
            noHTMLString = noHTMLString.replaceAll('\\<.*?\\>', '');
            noHTMLString = noHTMLString.replaceAll('<br/>', '\n' );
            noHTMLString = noHTMLString.replaceAll('&#39;', '\'');
            noHTMLString = noHTMLString.replaceAll('&#160;', '\'');
            noHTMLString = noHTMLString.replaceAll('&quot;','\"');
            return noHTMLString;
        }catch(Exception e){
            return htmlString;
        }
    }

    global void finish(Database.BatchableContext bc){
    }
    
}