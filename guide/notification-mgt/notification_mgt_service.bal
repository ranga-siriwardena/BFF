import ballerina/io;
import ballerina/config;
import ballerina/http;
import ballerina/log;

endpoint http:Listener listener {
    port: 9094
};

// Notification management is done using an in-memory map.
// Add some sample notifications to 'notificationMap' at startup.
map<json> notificationMap;


// RESTful service.
@http:ServiceConfig { basePath: "/notification-mgt" }
service<http:Service> notification_service bind listener {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/notification"
    }
    addNotification(endpoint client, http:Request req) {

        log:printInfo("addNotification!!!");

        json notificationReq = check req.getJsonPayload();
        log:printInfo(notificationReq.toString());
        string notificationId = notificationReq.Notification.ID.toString();
        notificationMap[notificationId] = notificationReq;

        // Create response message.
        json payload = { status: "Notification Created.", notificationId: notificationId };
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
        path: "/notification/list"
    }
    getNotifications(endpoint client, http:Request req) {
        log:printInfo("getNotifications!!!");

        http:Response res = new;
        json notificationsResponse = { Notifications: [] };

        int i = 0;
        foreach k, v in notificationMap {
            json notificationValue = v.Notification;
            log:printInfo(notificationValue.toString());
            notificationsResponse.Notifications[i] = notificationValue;
            i++;
        }

        log:printInfo(notificationsResponse.toString());

        // Set the JSON payload in the outgoing response message.
        res.setJsonPayload(notificationsResponse);

        // Send response to the client.
        client->respond(res) but {
            error e => log:printError(
                           "Error sending response", err = e)
        };
    }


}
