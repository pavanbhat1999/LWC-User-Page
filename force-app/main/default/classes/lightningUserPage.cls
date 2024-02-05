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
            List<User> usr = [select name,id,alias,Profile.name,UserRole.name,Country from User where name LIKE :UserName or alias LIKE :UserName order by name limit 50];
            return usr;
        }
        @AuraEnabled
        public static List<User> getUserDetail(String UserId)
        {
            List<User> usr = [select name,id,alias,email,profile.name,userrole.name,Country,IsActive from User where id=:UserId];
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
            List<PermissionSet> A = [SELECT Id, Name  FROM PermissionSet where NOT Name LIKE '%X00%' order by Name ];
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
        // Insert User Single
        @AuraEnabled
        public static String insertUser(String firstName,String lastName,String UserName,String Email,String Alias,Boolean isActive,String Profile,String TimeZone){
            try {
                
                    User newuser = new User();
                    System.debug('user Alias'+ Alias);
                    newuser.Alias = alias;
                    newuser.FirstName = FirstName;
                    newuser.LastName = LastName;
                    newuser.Username = Username;
                    newuser.Email = Email;
                    //newuser.Country = Country;
                    //newuser.Department = Department;
                    //newuser.FederationIdentifier = FederationIdentifier;
                    //newuser.IsActive = usr.IsActive;
                    newuser.IsActive = false;
                    //newuser.Profileid = ProfileId;
                    newuser.TimeZoneSidKey = TimeZone;
                    newUser.LocaleSidKey = 'en_US';
                    newUser.EmailEncodingKey = 'UTF-8';
                    newUser.ProfileId = '00E3X000002OI0QUAW' ;
                    newUser.LanguageLocaleKey = 'en_US';
                   // newuser.CommunityNickname = CommunityNickname;
                    //insertUsersList.add(newuser);
                System.debug('New User = '+ newuser);
              // System.debug('User Single'+ insertUsersList);
               //insert(insertUsersList);
               return 'usercreation Successfull';
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
                
            }
        }
        // Insert User Bulk
        @AuraEnabled
        public static String insertUserBulk(String userJSON){
            try {
                System.debug('Inserting the bulk user String =  '+userJSON);
                List<customUser> listUsers = (List<customUser>) JSON.deserialize(userJSON, List<customUser>.class);
                List<User> insertUsersList = new List<User>();
                
                for(customUser usr:listUsers){
                    User newuser = new User();
                    System.debug('user name'+ usr.Alias);
                    if(usr.Alias == null) //!Added to handle empty row submission
                        break;
                    newuser.Alias = usr.alias;
                    newuser.FirstName = usr.FirstName;
                    newuser.LastName = usr.LastName;
                    newuser.Username = usr.Username;
                    newuser.Email = usr.Email;
                    newuser.Country = usr.Country;
                    newuser.Department = usr.Department;
                    newuser.FederationIdentifier = usr.FederationIdentifier;
                    //newuser.IsActive = usr.IsActive;
                    newuser.TimeZoneSidKey = usr.TimeZoneSidKey;
                    newuser.LocaleSidKey = usr.LocaleSidKey;
                    newuser.EmailEncodingKey = usr.EmailEncodingKey;
                    newuser.LanguageLocaleKey = usr.LanguageLocaleKey;
                    newuser.CommunityNickname = usr.CommunityNickname;
                    newuser.IsActive = false;
                    String profileSearch = usr.ProfileId;
                    Profile myProfile = [SELECT Id FROM Profile WHERE Name = :profileSearch LIMIT 1];
                    //newuser.Profileid = ProfileId;
                    //newuser.TimeZoneSidKey = TimeZone;
                    newUser.LocaleSidKey = 'en_US';
                    newUser.EmailEncodingKey = 'UTF-8';
                    newUser.LanguageLocaleKey = 'en_US';
                    newUser.ProfileId = myProfile.Id ;
                    //insertUsersList.add(newuser);
                    Database.SaveResult sr = Database.insert(newuser, false);
                    if (sr.isSuccess()) {
                        // Retrieve the ID of the new record
                        Id newRecordId = sr.getId();
                        System.debug('New Record ID: ' + newRecordId);
                        List<String> queues = usr.Groups.split(';');
                        System.debug('Queues each = '+queues);
                        Integer res = lightningUserPage.insertQueueForUser(queues,newRecordId);
                    } else {
                        // Handle the error if the insertion was not successful
                        for (Database.Error error : sr.getErrors()) {
                            System.debug('Error message: ' + error.getMessage());
                        }
                    }
                    System.debug('Groups = '+ usr.Groups);
    
                }
               //System.debug('User List'+ insertUsersList);
               //insert(insertUsersList);
               return 'usercreation Successfull';
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
                
            }
        }
        // Update the  User
       
        @AuraEnabled
        public static void updateUser(String UserId,String FirstName,String LastName,String Alias,Boolean IsActive){
            try {
                User usr = [Select Id,FirstName,LastName from User where Id=:UserId];
                usr.FirstName = FirstName;
                usr.LastName = LastName;
                usr.Alias = Alias;
                usr.IsActive = IsActive;
                update usr;
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        } 
        // Insert GroupMembership for the user
        @AuraEnabled
        public static Integer insertQueueForUser(List<String> QueueName,String UserId)
        {
          
    
            // * Inserting Queue Membership
            List<group> qids = [select Id from group where name in :QueueName];
            if(qids.isEmpty()){
                return 0;
            }
            //!remove afterwards List<Id> groupIds = new List<Id>();
            // for (Group qid : qids) {
            //     groupIds.add(qid.Id);
            // }
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