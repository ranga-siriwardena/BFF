import ballerina/test;
import ballerina/http;

endpoint http:Client clientEP {
    url:"http://localhost:9090/mobile-bff"
};

@test:Config
// Function to test POST resource 'getUserProfile'.
function testResourceGetUserProfile() {
    http:Response response = check clientEP -> get("/profile");
    // Expected response code is 200.
    test:assertEquals(response.statusCode, 200,
        msg = "getUserProfile resource did not respond with expected response code!");

}