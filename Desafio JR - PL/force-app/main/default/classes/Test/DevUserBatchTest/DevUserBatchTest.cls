@isTest
public class DevUserBatchTest {
    
    @isTest
    public static void completedRecords(){
        DevUser__c devUserTest = new DevUser__c(Name = 'Teste User', Login__c = 'octocat');
        insert devUserTest;
        
        String mockResponse = '{"login":"octocat","id":583231,"type":"User","bio":"GitHub mascot"}';
        
        Test.setMock(HttpCalloutMock.class, new GitHubMock(200, mockResponse));
        
        Test.startTest();
        Database.executeBatch(new DevUserBatch(new Set<Id>{devUserTest.Id}));
        Test.stopTest();
        
        DevUser__c updatedDevUser = [SELECT Id, Login__c, ExternalId__c, Type__c, Bio__c FROM DevUser__c WHERE Id = :devUserTest.Id];
        System.assertEquals('octocat', updatedDevUser.Login__c, 'Login should be octocat');
        System.assertEquals(583231, updatedDevUser.ExternalId__c, 'ExternalId should be 583231');
        System.assertEquals('User', updatedDevUser.Type__c, 'Type should be User');
        System.assertEquals('GitHub mascot', updatedDevUser.Bio__c, 'Bio should be GitHub mascot');
    }
}