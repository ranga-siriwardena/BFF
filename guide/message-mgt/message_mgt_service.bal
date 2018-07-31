import ballerina/http;
import ballerina/log;

endpoint http:Listener listener {
    port: 9095
};

// Message management is done using an in-memory map.
// Add some sample messages to 'messageMap' at startup.
map<json> messageMap;


// RESTful service.
@http:ServiceConfig { basePath: "/message-mgt" }
service<http:Service> message_mgt_service bind listener {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/message"
    }
    addMessage(endpoint client, http:Request req) {

        log:printInfo("addMessage...");

        json messageReq = check req.getJsonPayload();
        string messageId = messageReq.Message.ID.toString();
        messageMap[messageId] = messageReq;

        // Create response message.
        json payload = { status: "Message Sent.", messageId: messageId };
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
        path: "/message/list"
    }
    getMessages(endpoint client, http:Request req) {

        log:printInfo("getMessages...");

        http:Response response = new;

        // Create a json array with Messages
        json messageResponse = { Messages: [] };

        // Get all Messages from map and add them to response
        int i = 0;
        foreach k, v in messageMap {
            json messageValue = v.Message;
            messageResponse.Messages[i] = messageValue;
            i++;
        }

        // Set the JSON payload in the outgoing response message.
        response.setJsonPayload(untaint messageResponse);

        // Send response to the client.
        client->respond(response) but {
            error e => log:printError(
                           "Error sending response", err = e)
        };
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/unread-message/list"
    }
    getUnreadMessages(endpoint client, http:Request req) {

        log:printInfo("getUnreadMessages...");

        http:Response response = new;

        // Create a json array with Messages
        json messageResponse = { Messages: [] };

        // Get all Messages from map and add them to response
        int i = 0;
        foreach k, v in messageMap {
            json messageValue = v.Message;
            string messageStatus = messageValue.Status.toString();
            if (messageStatus == "Unread"){
                messageResponse.Messages[i] = messageValue;
                i++;
            }

        }

        // Set the JSON payload in the outgoing response message.
        response.setJsonPayload(untaint messageResponse);

        // Send response to the client.
        client->respond(response) but {
            error e => log:printError(
                           "Error sending response", err = e)
        };
    }

}
