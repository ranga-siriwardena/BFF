import ballerina/io;
import ballerina/config;
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
service<http:Service> message_service bind listener {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/message"
    }
    addMessage(endpoint client, http:Request req) {

        log:printInfo("addMessage!!!");

        json messageReq = check req.getJsonPayload();
        log:printInfo(messageReq.toString());
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
        log:printInfo("getMessages!!!");

        http:Response res = new;

        // Create a json array with Messages
        json messageResponse = { Messages: [] };

        int i = 0;
        foreach k, v in messageMap {
            json messageValue = v.Message;
            log:printInfo(messageValue.toString());
            messageResponse.Messages[i] = messageValue;
            i++;
        }

        log:printInfo(messageResponse.toString());

        // Set the JSON payload in the outgoing response message.
        res.setJsonPayload(messageResponse);

        // Send response to the client.
        client->respond(res) but {
            error e => log:printError(
                           "Error sending response", err = e)
        };
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/unread-message/list"
    }
    getUnreadMessages(endpoint client, http:Request req) {
        log:printInfo("getUnreadMessages!!!");

        http:Response res = new;

        // Create a json array with Messages
        json messageResponse = { Messages: [] };

        int i = 0;
        foreach k, v in messageMap {
            json messageValue = v.Message;
            string messageStatus = messageValue.Status.toString();
            if (messageStatus == "Unread"){
                log:
                printInfo(messageValue.toString());
                messageResponse.Messages[i] = messageValue;
                i++;
            }

        }

        log:printInfo(messageResponse.toString());

        // Set the JSON payload in the outgoing response message.
        res.setJsonPayload(messageResponse);

        // Send response to the client.
        client->respond(res) but {
            error e => log:printError(
                           "Error sending response", err = e)
        };
    }

}
