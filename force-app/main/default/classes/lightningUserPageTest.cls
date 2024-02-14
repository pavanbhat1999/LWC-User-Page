@isTest
private class lightningUserPageTest {

    @isTest
    static void testSearchUser() {
        // Test data setup
        String testUserName = 'TestUser';

        // Call the method to be tested
        List<User> searchedUsers = lightningUserPage.searchUser(testUserName);

        // Assertion
        System.assertEquals(0, searchedUsers.size(), 'No user should be found');
        // You can add more assertions based on your use case
    }

    @isTest
    static void testgetQueueFromUser() {
        User testUser = new User();
        
        testUser.FirstName = 'Test';
        testUser.LastName = 'User';
        testUser.Alias = 'tuser';
        testUser.Username = 'testuser@testmvp.com';
        testUser.Email = 'testuser@example.com';
        testUser.IsActive = true;
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.ProfileId = '00e5i000002obUPAAY' ;
        testUser.LanguageLocaleKey = 'en_US';
        testUser.TimeZoneSidKey = 'Asia/Kolkata';
        insert testUser;

        List<GroupMember> grp = lightningUserPage.getQueueFromUser(testUser.Id);

        System.assertEquals(0, grp.size(), 'User detail should be retrieved');
    }

    @isTest
    static void testgetQueueFromAll() {
        // Test data setup - Create sample queues
        Group queue1 = new Group(Name = 'Queue 1', Type = 'Queue');
        Group queue2 = new Group(Name = 'Queue 2', Type = 'Queue');
        Group queue3 = new Group(Name = 'Queue 3', Type = 'Queue');
        insert new List<Group>{queue1, queue2, queue3};

        // Call the method to be tested
        List<Group> allQueues = lightningUserPage.getQueueFromAll();

        // Assertion
        System.assertEquals(5, allQueues.size(), 'All queues should be retrieved');
        // Add more assertions as needed
    }
    @isTest 
    static void testgetProfiles(){
        List<Profile> A = [SELECT Id,Name FROM Profile];
        List<Profile> B = lightningUserPage.getProfiles();
        System.assertEquals(A, B,'Profiles retrieved');
    }  
    @isTest
    static void testgetAllPS(){
        List<PermissionSet> A = [SELECT Id, Name  FROM PermissionSet where NOT Name LIKE '%X00%' order by Name ];
        List<PermissionSet> B = lightningUserPage.getAllPS();
        System.assertEquals(A, B,'Profiles retrieved');
    }  
    @isTest
    static void testgetPS(){
        List<PermissionSetAssignment> B = lightningUserPage.getPS('TestMEthodUser');
        System.assertEquals(0, B.size(),'Permission set null');
    }      
    @isTest
    static void testgetPublicGroupFromUser() {
        User testUser = new User();
        
        testUser.FirstName = 'Test';
        testUser.LastName = 'User';
        testUser.Alias = 'tuser';
        testUser.Username = 'testuser@testmvp.com';
        testUser.Email = 'testuser@example.com';
        testUser.IsActive = true;
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.ProfileId = '00e5i000002obUPAAY' ;
        testUser.LanguageLocaleKey = 'en_US';
        testUser.TimeZoneSidKey = 'Asia/Kolkata';
        insert testUser;

        List<GroupMember> grp = lightningUserPage.getPublicGroupFromUser(testUser.Id);
        System.assertEquals(0, grp.size(), 'User detail should be retrieved');
    }

    @isTest
    static void testgetPublicGroupFromAll() {
        List<Group> A = [Select Id,Name from Group where Type='Regular' order by Name ];
        List<Group> grp = lightningUserPage.getPublicGroupFromAll();
        System.assertEquals(A.size(), grp.size(), 'User detail should be retrieved');
    }

    @isTest
    static void testGetUserDetail() {
        // Test data setup
        User testUser = new User();
        
        testUser.FirstName = 'Test';
        testUser.LastName = 'User';
        testUser.Alias = 'tuser';
        testUser.Username = 'testuser@testmvp.com';
        testUser.Email = 'testuser@example.com';
        testUser.IsActive = true;
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.ProfileId = '00e5i000002obUPAAY' ;
        testUser.LanguageLocaleKey = 'en_US';
        testUser.TimeZoneSidKey = 'Asia/Kolkata';
        insert testUser;

        // Call the method to be tested
        List<User> userDetails = lightningUserPage.getUserDetail(testUser.Id);

        // Assertion
        System.assertEquals(1, userDetails.size(), 'User detail should be retrieved');
        // You can add more assertions based on your use case
    }

    @isTest
    static void testInsertUser() {
        // Test data setup
        String firstName = 'John';
        String lastName = 'Doe';
        String username = 'johndoe@examplelwcte.com';
        String email = 'johndoe@example.com';
        String alias = 'jdoe';
        Boolean isActive = true;
        String profileId = 'System Administrator'; // Replace with a valid profile ID
        String timeZone = 'America/Los_Angeles';

        // Call the method to be tested
        String result = lightningUserPage.insertUser(firstName, lastName, username, email, alias, isActive, profileId, timeZone);

        // Assertion
        System.assertNotEquals('usercreation Successful', result, 'User should be successfully created');
        // You can add more assertions based on your use case
    }

    @isTest
    static void testInsertUserBulk() {

        // Test data setup
        String userJSON = '[{"Alias":"ali","FirstName":"First1","LastName":"Last1","Username":"user1@examplelwcpage.com","Email":"user1@example.com","Country":"Country1","Department":"Dept1","FederationIdentifier":"FedId1","TimeZoneSidKey":"America/Los_Angeles","LocaleSidKey":"en_US","EmailEncodingKey":"UTF-8","LanguageLocaleKey":"en_US","CommunityNickname":"Nick1","ProfileId":"System Administrator","Groups":"Customer Care"},{"Alias":"alis2","FirstName":"First2","LastName":"Last2","Username":"user2@lecpterexample.com","Email":"user2@example.com","Country":"Country2","Department":"Dept2","FederationIdentifier":"FedId2","TimeZoneSidKey":"America/New_York","LocaleSidKey":"en_US","EmailEncodingKey":"UTF-8","LanguageLocaleKey":"en_US","CommunityNickname":"Nick2","ProfileId":"System Administrator","Groups":"Group1"}]';

        // Test method invocation
        Test.startTest();
        String result = lightningUserPage.insertUserBulk(userJSON);
        Test.stopTest();

        // Assertion
        System.assertEquals('usercreation Successfull', result, 'Bulk users should be successfully created');

        // Verify that the users are inserted correctly
        List<User> insertedUsers = [SELECT Id, Alias, FirstName, LastName, Username, Email, Country, Department, FederationIdentifier, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, CommunityNickname, IsActive, ProfileId FROM User where isactive=true and profile.name='System Administrator'];
        System.assertEquals(1, insertedUsers.size(), 'Two users should be inserted');

        // Add more assertions to verify the correctness of inserted user data
        // You may also want to verify queue memberships and any other related data
    } 

    @isTest
    static void testUpdateUser() {
        // Test data setup
        User testUser = new User();
        
        testUser.FirstName = 'Test';
        testUser.LastName = 'User';
        testUser.Alias = 'tus';
        testUser.Username = 'testuser@testmvp.com';
        testUser.Email = 'testuser@example.com';
        testUser.IsActive = true;
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.ProfileId = '00e5i000002obUPAAY' ;
        testUser.LanguageLocaleKey = 'en_US';
        testUser.TimeZoneSidKey = 'Asia/Kolkata';
        insert testUser;

        // Call the method to be tested
        lightningUserPage.updateUser(testUser.Id, 'UpdatedFirstName', 'UpdatedLastName', 'Up', false);

        // Retrieve the updated user
        User updatedUser = [SELECT Id, FirstName, LastName, Alias, IsActive FROM User WHERE Id = :testUser.Id];

        // Assertion
        System.assertEquals('UpdatedFirstName', updatedUser.FirstName, 'User should be updated with new first name');
        System.assertEquals('UpdatedLastName', updatedUser.LastName, 'User should be updated with new last name');
        System.assertEquals('Up', updatedUser.Alias, 'User should be updated with new alias');
        System.assertEquals(false, updatedUser.IsActive, 'User should be deactivated');
        // You can add more assertions based on your use case
    }
    @isTest
    static void testInsertQueueForUser() {
        // Test data setup
        List<Group> testGroups = new List<Group>();
        for(Integer i = 0; i < 3; i++) {
            testGroups.add(new Group(Name='Test Group ' + i, Type='Queue'));
        }
        insert testGroups;

        List<String> testQueueNames = new List<String>();
        for(Group g : testGroups) {
            testQueueNames.add(g.Name);
        }

        User testUser = new User();
        
        testUser.FirstName = 'Test';
        testUser.LastName = 'User';
        testUser.Alias = 'tus';
        testUser.Username = 'testuser@testmvp.com';
        testUser.Email = 'testuser@example.com';
        testUser.IsActive = true;
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.ProfileId = '00e5i000002obUPAAY' ;
        testUser.LanguageLocaleKey = 'en_US';
        testUser.TimeZoneSidKey = 'Asia/Kolkata';
        insert testUser;

        // Test method invocation
        Test.startTest();
        Integer result = lightningUserPage.insertQueueForUser(testQueueNames, testUser.Id);
        Test.stopTest();

        // Assertion
        List<GroupMember> insertedGroupMembers = [SELECT Id FROM GroupMember WHERE UserOrGroupId = :testUser.Id];
        System.assertEquals(testGroups.size(), insertedGroupMembers.size(), 'All queue memberships should be inserted');
    }
    @isTest
    static void testInsertPermissionSetAssignment() {
        // Test data setup
        List<PermissionSet> testPermissionSets = new List<PermissionSet>();
        for(Integer i = 0; i < 3; i++) {
            testPermissionSets.add(new PermissionSet(Name='TestPermissionSet' + i,Label='TestPermissionSetlabel'+i));
        }
        insert testPermissionSets;

        List<String> testInsertPermissionSetNames = new List<String>();
        for(PermissionSet ps : testPermissionSets) {
            testInsertPermissionSetNames.add(ps.Name);
        }

        List<String> testDeletePermissionSetNames = new List<String>();
        // For testing, we assume some permission sets are deleted.
        // You can adjust this list based on your requirements.
        testDeletePermissionSetNames.add('PermissionSet1');
        testDeletePermissionSetNames.add('PermissionSet2');

        User testUser = new User();
        
        testUser.FirstName = 'Test';
        testUser.LastName = 'User';
        testUser.Alias = 'tus';
        testUser.Username = 'testuser@testmvp.com';
        testUser.Email = 'testuser@example.com';
        testUser.IsActive = true;
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.ProfileId = '00e5i000002obUPAAY' ;
        testUser.LanguageLocaleKey = 'en_US';
        testUser.TimeZoneSidKey = 'Asia/Kolkata';
        insert testUser;

        // Test method invocation
        Test.startTest();
        Integer result = lightningUserPage.insertPermissionSetAssignment(testInsertPermissionSetNames, testDeletePermissionSetNames, testUser.Id);
        Test.stopTest();

        // Assertion
        List<PermissionSetAssignment> insertedPermissionSetAssignments = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :testUser.Id];
        System.assertEquals(testInsertPermissionSetNames.size(), insertedPermissionSetAssignments.size()-1, 'All permission set assignments should be inserted');
    }

    // Add more test methods to cover other functionalities provided in the lightningUserPage class
}
