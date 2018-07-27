import ballerina/io;
import ballerina/config;
import ballerina/http;
import ballerina/log;

endpoint http:Listener listener {
    port: 9093
};

// Medical Record management is done using an in-memory map.
// Add some sample Medical Records to 'medicalRecordMap' at startup.
map<json> medicalRecordMap;


// RESTful service.
@http:ServiceConfig { basePath: "/medical_records" }
service<http:Service> medical_record_service bind listener {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/medical-record"
    }
    addMedicalRecord(endpoint client, http:Request req) {

        log:printInfo("addMedicalRecord!!!");

        json medicalRecordtReq = check req.getJsonPayload();
        log:printInfo(medicalRecordtReq.toString());
        string medicalRecordId = medicalRecordtReq.MedicalRecord.ID.toString();
        medicalRecordMap[medicalRecordId] = medicalRecordtReq;

        // Create response message.
        json payload = { status: "Medical Record Created.", medicalRecordId: medicalRecordId };
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
        path: "/medical-record/list"
    }
    getMedicalRecords(endpoint client, http:Request req) {
        log:printInfo("getMedicalRecords!!!");

        http:Response res = new;
        json medicalRecordsResponse = { MedicalRecords: [] };

        int i = 0;
        foreach k, v in medicalRecordMap {
            json medicalRecordValue = v.MedicalRecord;
            log:printInfo(medicalRecordValue.toString());
            medicalRecordsResponse.MedicalRecords[i] = medicalRecordValue;
            i++;
        }

        log:printInfo(medicalRecordsResponse.toString());

        // Set the JSON payload in the outgoing response message.
        res.setJsonPayload(untaint medicalRecordsResponse);

        // Send response to the client.
        client->respond(res) but {
            error e => log:printError(
                           "Error sending response", err = e)
        };
    }

}
