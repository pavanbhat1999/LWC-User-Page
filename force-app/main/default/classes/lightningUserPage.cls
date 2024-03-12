//CreatedBy - PVNB 
//Date - 25-02-2023
public class lightningUserPage {
        public class customUser
        {
            @InvocableVariable
            public string Alias;
            @InvocableVariable
            public string Country;
            @InvocableVariable
            public string Department;
            @InvocableVariable
            public string Email;
            @InvocableVariable
            public string FederationIdentifier;
            @InvocableVariable
            public string FirstName;
            @InvocableVariable
            public string IsActive;
            @InvocableVariable
            public string LastName;
            
            @InvocableVariable
            public string ProfileId;
            @InvocableVariable
            public string Username;
            @InvocableVariable
            public string TimeZoneSidKey;
            @InvocableVariable
            public string LocaleSidKey;
            @InvocableVariable
            public string EmailEncodingKey;
            @InvocableVariable
            public string LanguageLocaleKey;
            @InvocableVariable
            public string CommunityNickname;
            @InvocableVariable
            public string Groups;
        }
        @AuraEnabled
        public static List<User> searchUser(String UserName)
        {
            UserName = '%' + UserName + '%';
            List<User> usr = [select name,id,alias,username,Profile.name,UserRole.name,Country,isactive from User where (name LIKE :UserName or alias LIKE :UserName or Profile.name LIKE :Username) and Profile.name!=null order by createddate limit 50];
            return usr;
        }
        @AuraEnabled
        public static List<User> getUserDetail(String UserId)
        {
            List<User> usr = [select name,id,alias,username,email,profile.name,userrole.name,Country,IsActive from User where id=:UserId order by createddate desc];
            return usr;
        }
        // Getting Queue membership of individual user
        @AuraEnabled
        public static List<GroupMember> getQueueFromUser(String Id)
        {
            
            List<GroupMember> A = [Select Id,Group.Name from GroupMember where Group.type='Queue' and UserOrGroupId = :Id  ];
            return A;
        }
        // Fetch All queues present in Org
        @AuraEnabled
        public static List<Group> getQueueFromAll()
        {
            List<Group> A = [Select Id,Name from Group where Type='Queue' order by Name ];
            return A;
        }
        // Fetch Public groups from user 
        @AuraEnabled
        public static List<GroupMember> getPublicGroupFromUser(String Id)
        {
            List<GroupMember> A = [Select Id,Group.Name from GroupMember where Group.type='Regular' and UserOrGroupId = :Id  ];
            return A;
        }
        //    
        // Fetch All Public groups from user 
        @AuraEnabled
        public static List<Group> getPublicGroupFromAll()
        {
            List<Group> A = [Select Id,Name from Group where Type='Regular' order by Name ];
            return A;
        }
        // Fetch All Permission Sets
        @AuraEnabled
        public static List<PermissionSet> getAllPS()
        {
            List<PermissionSet> A = [SELECT Id, Name,IsOwnedByProfile,License.name,CreatedBy.name,IsCustom  FROM PermissionSet where (NOT Name LIKE '%X00%') and License.Name='Salesforce' and CreatedBy.name !=null and iscustom=true order by Name];
            return A;
        }
        // Fetch Permission Set of the User
        @AuraEnabled
        public static List<PermissionSetAssignment> getPS(String usernameps)
        {
            List<PermissionSetAssignment> A = [SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE  AssigneeId = :usernameps and (NOT permissionset.Name LIKE '%X00%')  order by Permissionset.name];
            return A;
        }
        // Fetch All profile names 
        @AuraEnabled
        public static List<Profile> getProfiles()
        {
            
            List<Profile> A = [SELECT Id,Name FROM Profile];
            return A;
        }
        // Fetch All userRoles
        @AuraEnabled
        public static List<UserRole> getUserRoles(){
          
                List<UserRole> A = [select id,name from UserRole ];
                return A;
         
        }
        // Insert User Single
        @AuraEnabled
    public static String insertUser(String firstName,String lastName,String UserName,String Email,String Alias,Boolean isActive,String Profile,String TimeZone,String UserRole){
        try {
            
                Profile myProfile = [SELECT Id FROM Profile WHERE Name = :Profile LIMIT 1];
                User newUser = new User();
                System.debug('user Alias'+ Alias);
                newUser.Alias = alias;
                newUser.FirstName = FirstName;
                newUser.LastName = LastName;
                newUser.Username = Username;
                newUser.Email = Email;
                //newUser.Country = Country;
                //newUser.Department = Department;
                //newUser.FederationIdentifier = FederationIdentifier;
                //newUser.IsActive = usr.IsActive;
                //!fix this
                newUser.IsActive = true;
                //newUser.Profileid = ProfileId;
                newUser.TimeZoneSidKey = TimeZone;
                newUser.LocaleSidKey = 'en_US';
                newUser.EmailEncodingKey = 'UTF-8';
                newUser.ProfileId = myProfile.Id ;
                if(UserRole != ''){
                    UserRole myRole = [select id from UserRole where Name = :UserRole LIMIT 1];
                    if(myRole!=null)
                    newUser.UserRoleId = myRole.Id;
                }
                newUser.LanguageLocaleKey = 'en_US';
               // newUser.CommunityNickname = CommunityNickname;
                //insertUsersMap.add(newUser);
            System.debug('New User = '+ newUser);
            Database.SaveResult sr =Database.insert(newUser);
            if (sr.isSuccess()) {
                // Retrieve the ID of the new record
                Id newRecordId = sr.getId();
                System.debug('New Record ID: ' + newRecordId);
                return newRecordId;
            } else {
                // Handle the error if the insertion was not successful
                for (Database.Error error : sr.getErrors()) {
                    System.debug('Error message: ' + error.getMessage());
                }
            }
            return 'error';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
            
        }
    }
        @AuraEnabled
        public static String insertUserBulk(String userJSON){
            try {
                System.debug('Inserting the bulk user String =  '+userJSON);
                List<customUser> listUsers = (List<customUser>) JSON.deserialize(userJSON, List<customUser>.class);
                System.debug('Converted User List  '+listUsers);
                Map<String,List<String>> insertUsersMap = new Map<String,List<String>>();
                List<User> insertUserList = new List<User>();
                // Store all profiles in a map to use in newUser
                Map<String, Id> profileMap = new Map<String, Id>();
                for (Profile p : [SELECT Id, Name FROM Profile]) {
                    profileMap.put(p.Name, p.Id);
                }
                
                for(customUser usr:listUsers){
                    User newUser = new User();
                    System.debug('user name'+ usr.Alias);
                    if(usr.Alias == null) //Added to handle empty row submission
                        break;
                    newUser.Alias = usr.alias;
                    newUser.FirstName = usr.FirstName;
                    newUser.LastName = usr.LastName;
                    newUser.Username = usr.Username;
                    newUser.Email = usr.Email;
                    newUser.Country = usr.Country;
                    newUser.Department = usr.Department;
                    newUser.FederationIdentifier = usr.FederationIdentifier;
                    //newUser.IsActive = usr.IsActive;
                    newUser.TimeZoneSidKey = usr.TimeZoneSidKey;
                    newUser.LocaleSidKey = usr.LocaleSidKey;
                    newUser.EmailEncodingKey = usr.EmailEncodingKey;
                    newUser.LanguageLocaleKey = usr.LanguageLocaleKey;
                    newUser.CommunityNickname = usr.CommunityNickname;
                    newUser.IsActive = false;
                    newUser.LocaleSidKey = 'en_US';
                    newUser.EmailEncodingKey = 'UTF-8';
                    newUser.LanguageLocaleKey = 'en_US';
                    if(profileMap.containsKey(usr.ProfileId)){
                        newUser.ProfileId = profileMap.get(usr.ProfileId);
                    }
                    else{
                        System.debug('Profile Not found');
                    }
                    //insertUsersMap.add(newUser);
                    List<String> queues = usr.Groups.split(';');
                    insertUsersMap.put(newUser.Username,queues);
                    insertUserList.add(newUser);
                }
                System.debug('User to be insert'+ insertUserList);
                Database.SaveResult[] sr = Database.insert(insertUserList, false);
                System.debug(sr);
                List<Id> successIds = new List<Id>();
                for(Database.SaveResult srItem : sr){
                    if(srItem.isSuccess())
                    successIds.add(srItem.getId());
                }
                List<User> userforQueueChange = [select Id, username from User where Id IN :successIds];
                for(User uq : userforQueueChange){
                    String userName = uq.username;
                    List<String> groups = insertUsersMap.get(uq.username);
                    if(!groups.isEmpty())
                    lightningUserPage.insertQueueForUser(groups,null, uq.id);
                }
                                
               return 'User creation process ran successfully';
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
                
            }
        }
        // Update the  User
       
        @AuraEnabled
        public static void updateUser(String UserId,String FirstName,String LastName,String Alias,Boolean IsActive,String Profile,String UserRole,String Username){
            try {
                User usr = [Select Id,FirstName,LastName from User where Id=:UserId];
                List<Profile> prof = [Select Id from profile where Name=:Profile limit 1];
                List<UserRole> usrRole = [Select Id from UserRole where Name=:UserRole limit 1];
                usr.FirstName = FirstName;
                usr.LastName = LastName;
                usr.Username = Username;
                usr.Alias = Alias;
                usr.IsActive = IsActive;
                usr.profileid = prof[0].id;
                if(usrRole.size()!=0)
                usr.userroleid = usrRole[0].id;
                update usr;
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        } 
        // Insert GroupMembership for the user
        @AuraEnabled
        public static Integer insertQueueForUser(List<String> QueueName,List<String> deleteQueues,String UserId)
        {
            // * Delete Queue Membership
            System.debug('logLevel'+deleteQueues);
            if(deleteQueues!=null){
                List<GroupMember> deleteqids = [select Id from groupmember where group.name in :deleteQueues];
                delete(deleteqids);
            }
          
            // * Inserting Queue Membership
            List<group> qids = [select Id from group where name in :QueueName];
            if(qids.isEmpty()){
                return 0;
            }
            List<GroupMember> lstgm = new List<GroupMember>();
            for (group q : qids){
                System.debug(q);
                GroupMember newgrp = new GroupMember(UserOrGroupId=UserId,groupID=q.Id); 
                lstgm.add(newgrp);
            }
            if(!lstgm.isEmpty()){
                insert(lstgm);
            }
            return 0;
        }
        // Insert permission set to the user
        @AuraEnabled
        public static Integer insertPermissionSetAssignment(List<String> insertPermissionSet,List<String> deletePermissionSet,String AssigneeId){
            try {
                // Delete the removed permission set
                List<permissionsetassignment> deleteList = [SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE  AssigneeId =:AssigneeId and permissionset.Name in :deletePermissionSet];
                delete deleteList;
                // insert newly selected premission set
                List<PermissionSet> insertPS = [select id from permissionset where name in :insertPermissionSet];
                List<PermissionSetAssignment> allPS = new List<PermissionSetAssignment>();
                for(PermissionSet ps:insertPS){
                    PermissionSetAssignment psa = new PermissionSetAssignment(permissionSetId=ps.Id,AssigneeId=AssigneeId);
                    allPS.add(psa);
                }
                insert(allPS);
                //PermissionSetAssignment psa = new PermissionSetAssignment(permissionSetId=pid,AssigneeId=AssigneeId);
                // insert psa;
                
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
            return 0;
        }
    
    
        }