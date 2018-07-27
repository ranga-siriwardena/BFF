import ballerina/io;
import ballerina/config;
import ballerina/http;
import ballerina/log;

endpoint http:Listener listener {
    port: 9092
};

// Appointment management is done using an in-memory map.
// Add some sample appointments to 'appointmetMap' at startup.
map<json> appointmentMap;


// RESTful service.
@http:ServiceConfig { basePath: "/appointment-mgt" }
service<http:Service> appointment_service bind listener {

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
        json payload = { status: "Appointment Created.", appointmentId: appointmentId };
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
        json appointmentsResponse = { Appointments: [] };

        int i = 0;
        foreach k, v in appointmentMap {
            json appointmentValue = v.Appointment;
            log:printInfo(appointmentValue.toString());
            appointmentsResponse.Appointments[i] = appointmentValue;
            i++;
        }

        log:printInfo(appointmentsResponse.toString());

        // Set the JSON payload in the outgoing response message.
        res.setJsonPayload(untaint appointmentsResponse);

        // Send response to the client.
        client->respond(res) but {
            error e => log:printError(
                           "Error sending response", err = e)
        };
    }


}
