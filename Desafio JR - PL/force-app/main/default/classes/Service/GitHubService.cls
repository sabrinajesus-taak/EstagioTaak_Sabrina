public with sharing class GitHubService {
    public static GitHubUserDTO buscarUsuario(String login) {
        if(login == null) {
            throw new IllegalArgumentException('Login cannot be null');
        }

        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.github.com/users/' + login);
        request.setMethod('GET');
        
        Http http = new Http();
        HttpResponse response = http.send(request);

        if(response.getStatusCode() == 200) {
            String responseBody = response.getBody();
            GitHubUserDTO userDTO = (GitHubUserDTO) JSON.deserialize(responseBody, GitHubUserDTO.class);
            return userDTO;
        } else {
            throw new CalloutException('Failed to fetch user data from GitHub. Status code: ' + response.getStatusCode());
        }
    }
}