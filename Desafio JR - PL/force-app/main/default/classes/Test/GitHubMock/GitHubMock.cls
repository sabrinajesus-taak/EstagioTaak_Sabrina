@isTest
public class GitHubMock implements HttpCalloutMock {

    private Integer statusCode;
    private String responseBody;

    public GitHubMock(Integer statusCode, String responseBody) {
        this.statusCode = statusCode;
        this.responseBody = responseBody;
    }
    
    public HTTPResponse respond(HTTPRequest request){
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        
        response.setBody(this.responseBody);
        response.setStatusCode(this.statusCode);
        
        return response;
    }
}