import ballerina/io;
import ballerina/config;
import ballerina/http;
import ballerina/log;

endpoint http:Listener listener {
    port: 9090
};


// Client endpoint to communicate with appointment management service
endpoint http:Client appointmentEP {
    url: "http://localhost:9092/appointment-mgt"
};

// Client endpoint to communicate with medical record service
endpoint http:Client medicalRecordEP {
    url: "http://localhost:9093/medical_records"
};

// Client endpoint to communicate with message management service
endpoint http:Client messageEP {
    url: "http://localhost:9095/message-mgt"
};


// RESTful service.
@http:ServiceConfig { basePath: "/mobile-bff" }
service<http:Service> mobile_bff_service bind listener {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/profile"
    }
    getUserProfile(endpoint client, http:Request req) {

        log:printInfo("getUserProfile!!!");


        // Call Appointment API and get appointment list
        json appointmentList = sendGetRequest(appointmentEP, "/appointment/list");
        log:printInfo(appointmentList.toString());

        // Call Medical Record API and get medical record list
        json medicalRecordList = sendGetRequest(medicalRecordEP, "/medical-record/list");
        log:printInfo(medicalRecordList.toString());

        // Call Message API and get unread message list
        json unreadMessageList = sendGetRequest(messageEP, "/unread-message/list");
        log:printInfo(unreadMessageList.toString());


        // Aggregate the responses
        json profileJson = {};
        profileJson.Appointments = appointmentList.Appointments;
        profileJson.MedicalRecords = medicalRecordList.MedicalRecords;
        profileJson.Messages = unreadMessageList.Messages;

        io:println(profileJson);


        http:Response response;
        response.setJsonPayload(untaint profileJson);


        // Send response to the client.
        _ = client->respond(response) but {
            error e => log:printError(
                           "Error sending response", err = e)
        };
    }

    // This API may have more resources for other functionalities
}

// Function which takes http client endpoint and context as a input
// This will call given endpoint and return a json response
function sendGetRequest(http:Client httpClient1, string context) returns (json) {

    endpoint http:Client client1 = httpClient1;

    var response = client1->get(context);

    json value;

    match response {
        http:Response resp => {
            io:println("GET request:");
            var msg = resp.getJsonPayload();
            match msg {
                json jsonPayload => {
                    io:println(jsonPayload);
                    value = jsonPayload;
                }
                error err => {
                    log:printError(err.message, err = err);
                }
            }
        }
        error err => {
            log:printError(err.message, err = err);
        }
    }

    return value;
}


