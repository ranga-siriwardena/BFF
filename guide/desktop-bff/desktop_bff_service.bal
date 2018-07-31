import ballerina/http;
import ballerina/log;

endpoint http:Listener listener {
    port: 9091
};


// Client endpoint to communicate with appointment management service
endpoint http:Client appointmentEP {
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
        log:printInfo("getAlerts...");

        // Call Notification API and get notification list
        json notificationList = sendGetRequest(notificationEP, "/notification/list");

        // Call Message API and get full message list
        json messageList = sendGetRequest(messageEP, "/message/list");

        // Generate the response from notification and message aggregation
        json alertJson = {};

        alertJson.Notifications = notificationList.Notifications;
        alertJson.Messages = messageList.Messages;

        // Set JSON payload to response
        http:Response response;
        response.setJsonPayload(untaint alertJson);

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
    getAppointments(endpoint client, http:Request req) {

        log:printInfo("getAppointments...");

        // Call Appointment API and get appointment list
        json appointmentList = sendGetRequest(appointmentEP, "/appointment/list");

        // Generate the response
        json appointmentJson = {};
        appointmentJson.Appointments = appointmentList.Appointments;

        // Set JSON payload to response
        http:Response response;
        response.setJsonPayload(untaint appointmentJson);

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

        log:printInfo("getMedicalRecords...");

        // Call Medical Record API and get medical record list
        json medicalRecordList = sendGetRequest(medicalRecordEP, "/medical-record/list");

        // Generate the response
        json medicalRecordJson = {};
        medicalRecordJson.MedicalRecords = medicalRecordList.MedicalRecords;

        // Set JSON payload to response
        http:Response response;
        response.setJsonPayload(untaint medicalRecordJson);

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
            var msg = resp.getJsonPayload();
            match msg {
                json jsonPayload => {
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
