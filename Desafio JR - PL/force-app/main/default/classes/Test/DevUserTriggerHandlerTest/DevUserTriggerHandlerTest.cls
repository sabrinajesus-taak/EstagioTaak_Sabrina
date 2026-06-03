@isTest
public class DevUserTriggerHandlerTest {

    @isTest
    public static void insertDevUserTest() {
        DevUser__c devUserTest = new DevUser__c(Name = 'Teste User', Login__c = 'octocat');

        String mockResponse = '{"login":"octocat","id":583231,"type":"User","bio":"GitHub mascot"}';
        Test.setMock(HttpCalloutMock.class, new GitHubMock(200, mockResponse));

        Test.startTest();
        insert devUserTest;
        Test.stopTest();

        DevUser__c insertedDevUser = [SELECT Id, Name, Login__c, ExternalId__c, Type__c, Bio__c FROM DevUser__c WHERE Id = :devUserTest.Id];
        System.assertNotEquals(null, insertedDevUser.Id, 'Record should be inserted');
        System.assertEquals('Teste User', insertedDevUser.Name, 'Name should be Teste User');
        System.assertEquals('octocat', insertedDevUser.Login__c, 'Login should be octocat');
        System.assertEquals(583231, insertedDevUser.ExternalId__c, 'ExternalId should be 583231');
        System.assertEquals('User', insertedDevUser.Type__c, 'Type should be User');
        System.assertEquals('GitHub mascot', insertedDevUser.Bio__c, 'Bio should be GitHub mascot');
    }
}