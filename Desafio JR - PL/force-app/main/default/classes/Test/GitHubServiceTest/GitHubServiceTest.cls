@isTest
private class GitHubServiceTest {

    @isTest
    static void validateLogin() {

        String mockResponse = '{"login": "octocat", "id": 583231, "type": "User", "bio": "GitHub mascot"}';
        Test.setMock(HttpCalloutMock.class, new GitHubMock(200, mockResponse));

        Test.startTest();
        GitHubUserDTO userDTO = GitHubService.buscarUsuario('octocat');
        Test.stopTest();

        System.assertEquals('octocat', userDTO.login, 'Login should be octocat');
        System.assertEquals(583231, userDTO.id, 'ID should be 583231');
        System.assertEquals('User', userDTO.type, 'Type should be User');
        System.assertEquals('GitHub mascot', userDTO.bio, 'Bio should be GitHub mascot');
    }

    @isTest
    static void invalidLogin() {
        Test.setMock(HttpCalloutMock.class, new GitHubMock(404, ''));

        try {
            GitHubService.buscarUsuario('invalidUser');
            System.assert(false, 'Expected CalloutException was not thrown');
        } catch (CalloutException e) {
            System.assert(e.getMessage().contains('Failed to fetch user data from GitHub'), 'Exception message should indicate callout failure');
        }
    }

}