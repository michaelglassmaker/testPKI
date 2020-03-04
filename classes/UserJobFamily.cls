public with sharing class UserJobFamily {
	private UserJobFamily() {}

	public static void handleJobFamily(List<User> newUsers, Map<Id,User> oldMap)
	{
		// find new users with a job family or old users with an updated job family
		Map<String,List<Id>> updatedUsers = new Map<String,List<Id>>();
		Map<String,List<Id>> deleteFrom = new Map<String,List<Id>>();
		List<Id> deleteAll = new List<Id>();
		User old;
		for(User u:newUsers)
		{
			if (u.License_type__c == 'Chatter Free')
			{
				System.debug('~~ SKIPPING Job Family Group.. Chatter Free Users cannot be members of Groups.');
				continue;				
			}

			String groupName = 'Job Family: '+u.PKI_GBL_Job_Family__c;
			old = oldMap == null ? null : oldMap.get(u.Id);
			if(u.PKI_GBL_Job_Family__c == null || u.IsActive == false)
			{
				deleteAll.add(u.Id);
			}
			else if((old == null || (u.IsActive == true && old.IsActive == false)) 
				&& u.PKI_GBL_Job_Family__c != null)
			{
				// handle new user job families
				if(!updatedUsers.containsKey(groupName))
				{
					updatedUsers.put(groupName, new List<Id> { u.Id });
				}
				else
				{
					updatedUsers.get(groupName).add(u.Id);
				}
			}
			else if (old != null && u.PKI_GBL_Job_Family__c != null && u.PKI_GBL_Job_Family__c != old.PKI_GBL_Job_Family__c)
			{
				// delete old job family group membership
				String oldGroupName = 'Job Family: '+old.PKI_GBL_Job_Family__c;
				if(!deleteFrom.containsKey(oldGroupName))
				{
					deleteFrom.put(oldGroupName, new List<Id> { u.Id });
				}
				else
				{
					deleteFrom.get(oldGroupName).add(u.Id);
				}

				// handle updated job families
				if(!updatedUsers.containsKey(groupName))
				{
					updatedUsers.put(groupName, new List<Id> { u.Id });
				}
				else
				{
					updatedUsers.get(groupName).add(u.Id);
				}
			}
		}

		if (!deleteAll.isEmpty())
			jobFamily_deleteAllMembers(deleteAll);

		if(updatedUsers.isEmpty()) return;

		// delete old group
		if(!deleteFrom.isEmpty())
		{
			jobFamily_deleteMembers(deleteFrom);
		}

		jobFamily_createMembers(updatedUsers);
	}

	public static void jobFamily_createMembers(Map<String,List<Id>> updatedUsers)
	{
		GroupMember tempMember;
		List<GroupMember> newMembers = new List<GroupMember>();

		// query for extant groups
		List<Group> groups;
		try
		{
			groups = [SELECT Id, Name FROM Group WHERE Name IN :updatedUsers.keySet()];
		}
		catch(Exception e)
		{
			System.debug('~~~ no groups found');
		}

		// if groups are found, add users to the groups
		if(groups != null)
		{
			for(Group grp:groups)
			{
				if (updatedUsers.containsKey(grp.Name))
				{
					for(Id i:updatedUsers.get(grp.Name))
					{
						tempMember = new GroupMember();
						tempMember.GroupId = grp.Id;
						tempMember.UserOrGroupId = i;
						newMembers.add(tempMember);
					}
					updatedUsers.remove(grp.Name);
				}
			}
		}

		if(!updatedUsers.isEmpty())
		{
			// create new groups
			Group tempGroup;
			List<Group> newGroups = new List<Group>();
			for(String newGroup:updatedUsers.keySet())
			{
				tempGroup = new Group();
				tempGroup.Name = newGroup;
				newGroups.add(tempGroup);
			}

			insert newGroups;

			// add users to new groups
			for(Group newGroup:newGroups)
			{
				for(Id i:updatedUsers.get(newGroup.Name))
				{
					tempMember = new GroupMember();
					tempMember.GroupId = newGroup.Id;
					tempMember.UserOrGroupId = i;
					newMembers.add(tempMember);
				}
			}
		}

		insert newMembers;
	}

	public static void jobFamily_deleteAllMembers(List<Id> userIds)
	{
		List<GroupMember> groupMembers = 
			[SELECT Id, GroupId, UserOrGroupId 
			   FROM GroupMember 
			  WHERE Group.Name LIKE 'Job Family%'
			    AND UserOrGroupId IN :userIds];

		if (!groupMembers.isEmpty())
			delete groupMembers;
	}

	public static void jobFamily_deleteMembers(Map<String,List<Id>> deleteFrom)
	{
		List<Id> usersToDelete = new List<Id>();
		for(String grpName:deleteFrom.keySet())
		{
			for(Id i:deleteFrom.get(grpName))
			{
				usersToDelete.add(i);
			}
		} 

		List<Group> deleteGroups = [SELECT Id, Name FROM Group WHERE Name IN :deleteFrom.keySet()];
		Map<Id,String> groupMap = new Map<Id,String>();
		for(Group grp:deleteGroups)
		{
			groupMap.put(grp.Id,grp.Name);
		}

		List<GroupMember> groupMembers = 
			[SELECT Id, GroupId, UserOrGroupId 
			   FROM GroupMember 
			  WHERE GroupId IN :groupMap.keySet() 
			    AND UserOrGroupId IN :usersToDelete];

		// only delete records that match both group and user
		List<GroupMember> gmsToDelete = new List<GroupMember>();
		for(GroupMember gm:groupMembers)
		{
			for(Id i:deleteFrom.get(groupMap.get(gm.GroupId)))
			{
				if(gm.UserOrGroupId == i)
				{
					gmsToDelete.add(gm);
				}
			}
		}
		
		delete gmsToDelete;
	}
}