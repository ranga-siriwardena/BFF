import ballerina/io;
import ballerina/config;
import ballerina/http;
import ballerina/log;

endpoint http:Listener listener {
    port: 9092
};

// Appointment management is done using an in-memory map.
// Add some sample appointments to 'apoinmetMap' at startup.
map<json> appointmentMap;


// RESTful service.
@http:ServiceConfig { basePath: "/appointment-mgt" }
service<http:Service> apoinment_service bind listener {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/appointment"
    }
    addAppointment(endpoint client, http:Request req) {

        log:printInfo("addAppointment!!!");

        json appointmentReq = check req.getJsonPayload();
        log:printInfo(appointmentReq.toString());
        string appointmentId = appointmentReq.Appointment.ID.toString();
        appointmentMap[appointmentId] = appointmentReq;

        // Create response message.
        json payload = { status: "Appointment Created.", apoinmentId: appointmentId };
        http:Response response;
        response.setJsonPayload(untaint payload);

        // Set 201 Created status code in the response message.
        response.statusCode = 201;

        // Send response to the client.
        _ = client->respond(response) but {
            error e => log:printError(
                           "Error sending response", err = e)
        };
    }


    @http:ResourceConfig {
        methods: ["GET"],
        path: "/appointment/list"
    }
    getAppointments(endpoint client, http:Request req) {
        log:printInfo("getAppointments!!!");

        http:Response res = new;

        // Create a json array with Appointments
        json apoinmentsResponse = { Appoinments: [] };

        int i = 0;
        foreach k, v in appointmentMap {
            json apoinmentValue = v.Appointment;
            log:printInfo(apoinmentValue.toString());
            apoinmentsResponse.Appoinments[i] = apoinmentValue;
            i++;
        }

        log:printInfo(apoinmentsResponse.toString());

        // Set the JSON payload in the outgoing response message.
        res.setJsonPayload(apoinmentsResponse);

        // Send response to the client.
        client->respond(res) but {
            error e => log:printError(
                           "Error sending response", err = e)
        };
    }


}
