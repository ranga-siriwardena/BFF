import ballerina/io;
import ballerina/config;
import ballerina/http;
import ballerina/log;

endpoint http:Listener listener {
    port: 9091
};


// Client endpoint to communicate with appointment management service
endpoint http:Client appoinmentEP {
    url: "http://localhost:9092/appointment-mgt"
};

// Client endpoint to communicate with medical record service
endpoint http:Client medicalRecordEP {
    url: "http://localhost:9093/medical_records"
};

// Client endpoint to communicate with notification management service
endpoint http:Client notificationEP {
    url: "http://localhost:9094/notification-mgt"
};

// Client endpoint to communicate with message management service
endpoint http:Client messageEP {
    url: "http://localhost:9095/message-mgt"
};


// RESTful service.
@http:ServiceConfig { basePath: "/desktop-bff" }
service<http:Service> desktop_bff_service bind listener {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/alerts"
    }
    getAlerts(endpoint client, http:Request req) {

        // This will return all message and notifications
        log:printInfo("getAlerts!!!");


        // Call Notification API and get notification list
        json notificationList = sendGetRequest(notificationEP, "/notification/list");
        log:printInfo(notificationList.toString());

        // Call Message API and get full message list
        json messageList = sendGetRequest(messageEP, "/message/list");
        log:printInfo(messageList.toString());


        // Generate the response from notification and message aggregation
        json alertJson = {};

        alertJson.Notifications = notificationList.Notifications;
        alertJson.Messages = messageList.Messages;

        io:println(alertJson);


        http:Response response;
        response.setJsonPayload(alertJson);


        // Send response to the client.
        _ = client->respond(response) but {
            error e => log:printError(
                           "Error sending response", err = e)
        };
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/appointments"
    }
    getAppoinments(endpoint client, http:Request req) {

        // Call Appointment API and get appointment list
        json appoinmentList = sendGetRequest(appoinmentEP, "/appointment/list");
        log:printInfo(appoinmentList.toString());


        // Generate the response
        json apoinmentJson = {};

        apoinmentJson.Appoinments = appoinmentList.Appoinments;

        io:println(apoinmentJson);


        http:Response response;
        response.setJsonPayload(apoinmentJson);

        // Send response to the client.
        _ = client->respond(response) but {
            error e => log:printError(
                           "Error sending response", err = e)
        };
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/medical-records"
    }
    getMedicalRecords(endpoint client, http:Request req) {

        // Call Medical Record API and get medical record list
        json medicalRecordList = sendGetRequest(medicalRecordEP, "/medical-record/list");
        log:printInfo(medicalRecordList.toString());


        // Generate the response
        json medicalRecordJson = {};

        medicalRecordJson.Appoinments = medicalRecordList.MedicalRecords;

        io:println(medicalRecordJson);


        http:Response response;
        response.setJsonPayload(medicalRecordJson);

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
