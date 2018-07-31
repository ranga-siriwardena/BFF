# Backends For Frontends

Backends For Frontends is a service design pattern with the core idea of creating separate backend service for specific frontend application.This pattern will allow  each type of user experience to have separate backend service layer (shim). The design pattern has its own advantages and disadvantages and the usage is very much depending on the requirements. 

> In this guide you will learn about using  Backend For Frontends design pattern with Ballerina. 

The following are the sections available in this guide.

- [What you'll build](#what-youll-build)
- [Prerequisites](#prerequisites)
- [Implementation](#implementation)
- [Testing](#testing)
- [Deployment](#deployment)
- [Observability](#observability)

## What you’ll build
Let’s take a real world use case of online healthcare management system to understand how BFF works. A health care provider have a Desktop Application and a Mobile Application for their users to have better online experience. Once the user login to the Desktop application the home page information shown in Desktop application and Mobile application may vary. Specially the resource limitations in mobile device such as screen size, battery life and data usage cause the mobile application to show minimal viable information to the end user. Same time the Desktop counterpart can afford more information and do multiple network calls to get required data in place. So the design of the application is suppose to have two different BFFs to support each user experience. Here the BFF layer consumes existing downstream services and act as a shim to translate the required information for each user experience. Following diagram demonstrates the use case with two BFF services. 
 
![BFF Design](https://user-images.githubusercontent.com/8995220/43428119-81a10502-9411-11e8-8e24-4d32e0aebd12.jpeg)

In this use case we have two applications called Desktop Application and Mobile Application. For each application there is specific backend service (BFF) called Desktop BFF and Mobile BFF respectively. These BFFs consumes set of downstream services called Appointment Management Service, Medical Record Management Service, Notification Management Service and Message Management Service. For the purpose of the demonstration, Ballerina is used to build both BFF layer and downstream service layer. 

## Prerequisites

- [Ballerina Distribution](https://ballerina.io/learn/getting-started/)
- A Text Editor or an IDE

### Optional requirements
- Ballerina IDE plugins ([IntelliJ IDEA](https://plugins.jetbrains.com/plugin/9520-ballerina), [VSCode](https://marketplace.visualstudio.com/items?itemName=ballerina.ballerina), [Atom](https://atom.io/packages/language-ballerina))
- [Docker](https://docs.docker.com/engine/installation/)
- [Kubernetes](https://kubernetes.io/docs/setup/)

## Implementation

> If you want to skip the basics, you can download the git repo and directly move to the "Testing" section by skipping  "Implementation" section.

### Create the project structure

Ballerina is a complete programming language that supports custom project structures. Let's use the following package structure for this guide.

```
backend-for-frontend
  └── guide
      ├── appointment-mgt
      │   ├── appointment_mgt_service.bal
      │   └── tests
      │       └── appointment_mgt_service_test.bal
      ├── medical-record-mgt
      │   ├── medical_record_mgt_service.bal
      │   └── tests
      │       └── medical_record_mgt_service_test.bal
      ├── notification-mgt
      │   ├── notification_mgt_service.bal
      │   └── tests
      │       └── notification_mgt_service_test.bal
      ├── message-mgt
      │   ├── message_mgt_service.bal
      │   └── tests
      │       └── message_mgt_service_test.bal
      ├── mobile-bff
      │   ├── mobile_bff_service.bal
      │   └── tests
      │       └── mobile_bff_service_test.bal
      ├── desktop-bff
      │   ├── desktop_bff_service.bal
      │   └── tests
      │       └── desktop_bff_service_test.bal
      └── sample-data-publisher
          ├── sample_data_publisher.bal
          └── sample-data.toml
```

- Create the above directories in your local machine and also create empty `.bal` files.

- Then open the terminal and navigate to `backend-for-frontend/guide` and run Ballerina project initializing toolkit.
```bash
   $ ballerina init
```

### Developing the service

Let's implement the set of downstream services first.  

Appointment Management Service (appointment_mgt_service) is a REST API developed to manage health appointments for the members. For demonstration purpose it has a in-memory map to hold appointment data. It has capability to add appointments and retrieve appointments. 

##### Skeleton code for appointment_mgt_service.bal
```ballerina
import ballerina/http;

endpoint http:Listener listener {
   port: 9092
};

// Appointment management is done using an in-memory map.
// Add some sample appointments to 'appointmentMap' at startup.
map<json> appointmentMap;

// RESTful service.
@http:ServiceConfig { basePath: "/appointment-mgt" }
service<http:Service> appointment_service bind listener {

   @http:ResourceConfig {
       methods: ["POST"],
       path: "/appointment"
   }
   addAppointment(endpoint client, http:Request req) {
    // implementation  
   }

   @http:ResourceConfig {
       methods: ["GET"],
       path: "/appointment/list"
   }
   getAppointments(endpoint client, http:Request req) {
    // implementation       
   }

}
```

Medical Record Management Service (medical_record_mgt_service) is a REST API developed to manage medical records for the members. For demonstration purpose it has a in-memory map to hold medical record.  It has capability to add medical records and retrieve them. 

##### Skeleton code for medical_record_mgt_service.bal
```ballerina
import ballerina/http;

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
       // Implementation 
   }
 
   @http:ResourceConfig {
       methods: ["GET"],
       path: "/medical-record/list"
   }
   getMedicalRecords(endpoint client, http:Request req) {
       // Implementation 
   }
 
}

```

Notification Management Service (notification_mgt_service) is a REST API developed to manage notifications. For demonstration purpose it has a in-memory map to hold notifications.  It has capability to add notifications and retrieve them. 

##### Skeleton code for notification_mgt_service.bal
```ballerina
import ballerina/http;

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
       // Implementation 
   }


   @http:ResourceConfig {
       methods: ["GET"],
       path: "/notification/list"
   }
   getNotifications(endpoint client, http:Request req) {
       // Implementation 
   }


}

```

Message Management Service (message_mgt_service) is a REST API developed to manage messages. For demonstration purpose it has a in-memory map to hold messages.  It has capability to add messages, retrieve all messages and retrieve unread messages. 

##### Skeleton code for message_mgt_service.bal
```ballerina

import ballerina/http;

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

      // Implementation 
   }

   @http:ResourceConfig {
       methods: ["GET"],
       path: "/message/list"
   }
   getMessages(endpoint client, http:Request req) {
       // Implementation 
   }

   @http:ResourceConfig {
       methods: ["GET"],
       path: "/unread-message/list"
   }
   getUnreadMessages(endpoint client, http:Request req) {
       // Implementation 

}

```

Let’s look into the BFF implementation now. 

Mobile BFF(mobile_bff_service) is a shim used to support Mobile user experience. In this use case, when loading mobile application home page it calls a single resource in Mobile BFF and retrieve appointments, medical records and messages. Also the mobile apps having different method of sending notifications hence home page loading does not need to involve notification management service.  This will reduce number of backend calls and help to load the home pages in much efficient way. 

##### Skeleton code for mobile_bff_service.bal
```ballerina

import ballerina/http;

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

       // Call Appointment API and get appointment list

       // Call Medical Record API and get medical record list

       // Call Message API and get unread message list

       // Aggregate the responses 

       // Send response to the client.
      
   }

   // This API may have more resources for other functionalities
}

```

Desktop BFF(desktop_bff_service) is a shim used to support Desktop application user experience. In this use case, when loading desktop application home page it can offered to do multiple calls to its desktop_bff_service and retrieve comparatively large amount of data as per desktop application requirements.  In this use case Desktop application will call Desktop BFF separately to retrieve appointments and medical records. Also it will call Desktop BFF to retrieve Messages and Notifications in a single call. 

##### Skeleton code for desktop_bff_service.bal
```ballerina

import ballerina/http;

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

       // Call Notification API and get notification list

       // Call Message API and get full message list

       // Generate the response from notification and message aggregation 

       // Send response to the client.  
    }

   @http:ResourceConfig {
       methods: ["GET"],
       path: "/appointments"
   }
   getAppoinments(endpoint client, http:Request req) {
       // Call Appointment API and get appointment list

       // Generate the response
      
       // Send response to the client.
           
   }
   @http:ResourceConfig {
       methods: ["GET"],
       path: "/medical-records"
   }
   getMedicalRecords(endpoint client, http:Request req) {

       // Call Medical Record API and get medical record list
    
       // Generate the response

       // Send response to the client.
   }

   // This API may have more resources for other functionalities
}

```

## Testing

### Invoking the service

Navigate to BFF/guide and run following commands in separate terminals to start all downstream services. These commands will start appointment_mgt_service, appointment_mgt_service, notification_mgt_service and notification_mgt_service on ports 9092, 9093, 9094 and 9095 respectively. 

```bash
   $ ballerina run appointment-mgt 
```

```bash
   $ ballerina run medical-record-mgt
```

```bash
   $ ballerina run notification-mgt
```

```bash
   $ ballerina run message-mgt
```

Similarly run bellow commands to start the BFF layer services. These commands will start mobile_bff_service and desktop_bff_service on ports 9090 and 9091 respectively. 


```bash
   $ ballerina run mobile-bff 
```

```bash
   $ ballerina run desktop-bff
```

For demonstration purpose let’s add some data to downstream services. Use following command to load some appointments, medical records, notifications and messages to the services. 

```bash
   $ ballerina run sample-data-publisher --config sample-data-publisher/sample_data.toml 
```

Now we have some data loaded into the downstream services hence we can call the BFF layer to retrieve the data as per the requirement. 

Mobile application can call Mobile BFF to retrieve the user profile using a single API call. Following is a sample CURL commands. 

```bash
   $ curl -v -X GET http://localhost:9090/mobile-bff/profile

   Output:

   < HTTP/1.1 200 OK
   < content-type: application/json
   < content-length: 900
   < server: ballerina/0.980.1
 
   {
   "Appointments":[{"ID":"APT01","Name":"Family Medicine","Location":"Main Hospital","Time":"2018-08-23, 08.30AM","Description":"Doctor visit for family medicine"},{"ID":"APT02","Name":"Lab Test Appointment","Location":"Main Lab","Time":"2018-08-20, 07.30AM","Description":"Blood test"}],
   "MedicalRecords":[{"ID":"MED01","Name":"Fasting Glucose Test","Description":"Test Result for Fasting Glucose test is normal"},{"ID":"MED02","Name":"Allergies","Description":"Allergy condition recorded due to Summer allergies"}],
   "Messages":[{"ID":"MSG02","From":"Dr. Sandra Robert","Subject":"Regarding flu season","Content":"Dear member, We highly recommend you to get the flu vaccination to prevent yourself from flu","Status":"Unread"},{"ID":"MSG03","From":"Dr. Peter Mayr","Subject":"Regarding upcoming blood test","Content":"Dear member, Your Glucose test is scheduled in early next month","Status":"Unread"}]
   }
  
```

Desktop application can call Desktop BFF to render user profile using few API calls. Following are set of CURL commands which can use to invoke Desktop BFF. 

```bash
   $ curl -v -X GET http://localhost:9091/desktop-bff/appointments

   Output:

   < HTTP/1.1 200 OK
   < content-type: application/json
   < content-length: 286
   < server: ballerina/0.980.1

   {"Appointments":[{"ID":"APT01","Name":"Family Medicine","Location":"Main Hospital","Time":"2018-08-23, 08.30AM","Description":"Doctor visit for family medicine"},{"ID":"APT02","Name":"Lab Test Appointment","Location":"Main Lab","Time":"2018-08-20, 07.30AM","Description":"Blood test"}]}

```

```bash
   $ curl -v -X GET http://localhost:9091/desktop-bff/medical-records

   Output:

   < HTTP/1.1 200 OK
   < content-type: application/json
   < content-length: 229
   < server: ballerina/0.980.1

   {"MedicalRecords":[{"ID":"MED01","Name":"Fasting Glucose Test","Description":"Test Result for Fasting Glucose test is normal"},{"ID":"MED02","Name":"Allergies","Description":"Allergy condition recorded due to Summer allergies"}]}

```

```bash
   $ curl -v -X GET http://localhost:9091/desktop-bff/alerts

   Output:
   
   < HTTP/1.1 200 OK
   < content-type: application/json
   < content-length: 761
   < server: ballerina/0.980.1

   {
   "Notifications":[{"ID":"NOT01","Name":"Lab Test Result Notification","Description":"Test Result of Glucose test is ready"},{"ID":"NOT02","Name":"Flu Vaccine Status","Description":"Flu vaccines due for this year"}],
   "Messages":[{"ID":"MSG01","From":"Dr. Caroline Caroline","Subject":"Regarding Glucose test result","Content":"Dear member, your test result remain normal","Status":"Read"},{"ID":"MSG02","From":"Dr. Sandra Robert","Subject":"Regarding flu season","Content":"Dear member, We highly recommend you to get the flu vaccination to prevent yourself from flu","Status":"Unread"},{"ID":"MSG03","From":"Dr. Peter Mayr","Subject":"Regarding upcoming blood test","Content":"Dear member, Your Glucose test is scheduled in early next month","Status":"Unread"}]
   }

```


### Writing unit tests

In Ballerina, the unit test cases should be in the same package inside a folder named as 'tests'. When writing the test functions, follow the convention given below.
- Test functions should be annotated with `@test:Config`. See the following example.
```ballerina
   @test:Config
   function testResourceAddOrder() {
```

The source code for this guide contains unit test cases for each resource available in the BFF services implemented above.

To run the unit tests, open your terminal and navigate to `backend-for-frontend/guide`, and run the following command.
```bash
   $ ballerina test
```

> The source code for the tests can be found at [mobile_bff_service_test.bal](https://github.com/ranga-siriwardena/backend-for-frontend/blob/master/guide/mobile-bff/tests/mobile_bff_service_test.bal) and [desktop_bff_service_test.bal](https://github.com/ranga-siriwardena/backend-for-frontend/blob/master/guide/desktop-bff/tests/desktop_bff_service_test.bal).


## Deployment

Once you are done with the development, you can deploy the services using any of the methods listed below.

### Deploying locally

- As the first step, you can build Ballerina executable archives (.balx) of the services that we developed above. Navigate to `backend-for-frontend/guide` and run the following command.
```bash
   $ ballerina build <Package_Name>
```

- Once the .balx files are created inside the target folder, you can run them using the following command.
```bash
   $ ballerina run target/<Exec_Archive_File_Name>
```

- The successful execution of a services will show us something similar to the following output.
```
   ballerina: initiating service(s) in 'target/mobile-bff.balx'
   ballerina: started HTTP/WS endpoint 0.0.0.0:9090
```

### Deploying on Docker

You can run the service that we developed above as a Docker container. As Ballerina platform includes [Ballerina_Docker_Extension](https://github.com/ballerinax/docker), which offers native support for running ballerina programs on containers, you just need to put the corresponding Docker annotations on your service code.

Let's see how we can deploy the mobile_bff_service and desktop_bff_service we developed above on Docker. When invoking this service make sure that the other four services (appointment_mgt_service, medical_record_mgt_service, notification_mgt_service, and message_mgt_service) are also up and running.


- In our mobile_bff_service and desktop_bff_service, we need to import ballerinax/docker and use the annotation @docker:Config as shown below to enable Docker image generation during the build time.

##### Skeleton code for mobile_bff_service.bal
```ballerina
import ballerina/http;
import ballerinax/docker;

@docker:Config {
   registry:"ballerina.guides.io",
   name:"mobile_bff_service",
   tag:"v1.0"
}

@docker:Expose{}
endpoint http:Listener listener {
   port: 9090
};

// http:Client endpoint definitions to communicate with other services

// RESTful service.
@http:ServiceConfig { basePath: "/mobile-bff" }
service<http:Service> mobile_bff_service bind listener {
....
```

##### Skeleton code for desktop_bff_service.bal
```ballerina
import ballerina/http;
import ballerinax/docker;


@docker:Config {
    registry:"ballerina.guides.io",
    name:"desktop_bff_service",
    tag:"v1.0"
}

@docker:Expose{}
endpoint http:Listener listener {
    port: 9091
};

// http:Client endpoint definitions to communicate with other services

// RESTful service.
// RESTful service.
@http:ServiceConfig { basePath: "/desktop-bff" }
service<http:Service> desktop_bff_service bind listener {
....
```


- Now you can build Ballerina executable archives (.balx) of the services that we developed above, using following commands. This will also create the corresponding Docker images using the Docker annotations that you have configured above. Navigate to backend-for-frontend/guide and run the following command.

```
   $ballerina build mobile-bff

   Output: 
   
   Generating executable
    ./target/mobile-bff.balx
	@docker 		 - complete 3/3 

	Run following command to start docker container:
	docker run -d -p 9090:9090 ballerina.guides.io/mobile_bff_service:v1.0
```

```
   $ballerina build desktop-bff

   Output:
   
   Generating executable
    ./target/desktop-bff.balx
        @docker                  - complete 3/3

        Run following command to start docker container:
        docker run -d -p 9091:9091 ballerina.guides.io/desktop_bff_service:v1.0
```


- Once you successfully build the Docker images, you can run them with the `` docker run`` command that is shown in the previous step output section. Here we run the Docker images with flag`` -p <host_port>:<container_port>``. So that we use the host port 9090 and the container port 9090 for mobile_bff_service and we use the host port 9091 and the container port 9091 for desktop_bff_service. Therefore you can access the services through the host port.

```bash
   $ docker run -d -p 9090:9090 ballerina.guides.io/mobile_bff_service:v1.0
```

```bash
   $ docker run -d -p 9091:9091 ballerina.guides.io/desktop_bff_service:v1.0
```


- Verify Docker container is running with the use of `` $ docker ps`` command. The status of the Docker container should be shown as 'Up'.

```bash
   $ docker ps

   Output: 

   CONTAINER ID        IMAGE                                                 COMMAND                  CREATED             STATUS              PORTS                    NAMES
   f8bc7bf3a231        ballerina.guides.io/mobile_bff_service:v1.0           "/bin/sh -c 'balleri…"   4 minutes ago       Up 4 minutes        0.0.0.0:9090->9090/tcp   condescending_turing
   d64d7cea4b0b        ballerina.guides.io/desktop_bff_service:v1.0          "/bin/sh -c 'balleri…"   2 minutes ago       Up 3 minutes        0.0.0.0:9091->9091/tcp   thirsty_lamarr
```
- You can access the service using the same curl commands that we've used above.

```bash
   $ curl -v -X GET http://localhost:9090/mobile-bff/profile

   $ curl -v -X GET http://localhost:9091/desktop-bff/appointments

   $ curl -v -X GET http://localhost:9091/desktop-bff/medical-records

   $ curl -v -X GET http://localhost:9091/desktop-bff/alerts
```

### Deploying on Kubernetes

- You can run the services that we developed above, on Kubernetes. The Ballerina language offers native support for running a ballerina programs on Kubernetes, with the use of Kubernetes annotations that you can include as part of your service code. Also, it will take care of the creation of the Docker images. So you don't need to explicitly create Docker images prior to deploying it on Kubernetes. Refer to [Ballerina_Kubernetes_Extension](https://github.com/ballerinax/kubernetes) for more details and samples on Kubernetes deployment with Ballerina. You can also find details on using Minikube to deploy Ballerina programs.

- Let's now see how we can deploy our BFFs on Kubernetes. When invoking this service make sure that the other four services (appointment_mgt_service, medical_record_mgt_service, notification_mgt_service, and message_mgt_service) are also up and running.

- First we need to import `ballerinax/kubernetes` and use `@kubernetes` annotations as shown below to enable kubernetes deployment for the services we developed above.

> NOTE: You can use Minikube to try this out locally.

##### Skeleton code for mobile_bff_service.bal
```ballerina
import ballerina/http;
import ballerinax/kubernetes;

@kubernetes:Ingress {
  hostname:"ballerina.guides.io",
  name:"ballerina-guides-mobile-bff-service",
  path:"/"
}

@kubernetes:Service {
  serviceType:"NodePort",
  name:"ballerina-guides-mobile-bff-service"
}

@kubernetes:Deployment {
  image:"ballerina.guides.io/mobile_bff_service:v1.0",
  name:"ballerina-guides-mobile-bff-service"
}

endpoint http:Listener listener {
   port: 9090
};

// http:Client endpoint definitions to communicate with other services

// RESTful service.
@http:ServiceConfig { basePath: "/mobile-bff" }
service<http:Service> mobile_bff_service bind listener {
....
```

##### Skeleton code for desktop_bff_service.bal
```ballerina
import ballerina/http;
import ballerinax/kubernetes;

@kubernetes:Ingress {
  hostname:"ballerina.guides.io",
  name:"ballerina-guides-desktop-bff-service",
  path:"/"
}

@kubernetes:Service {
  serviceType:"NodePort",
  name:"ballerina-guides-desktop-bff-service"
}

@kubernetes:Deployment {
  image:"ballerina.guides.io/desktop_bff_service:v1.0",
  name:"ballerina-guides-desktop-bff-service"
}

endpoint http:Listener listener {
    port: 9091
};

// http:Client endpoint definitions to communicate with other services

// RESTful service.
// RESTful service.
@http:ServiceConfig { basePath: "/desktop-bff" }
service<http:Service> desktop_bff_service bind listener {
....
```

- Here we have used ``  @kubernetes:Deployment `` to specify the Docker image name that will be created as part of building this service.
- We have also specified `` @kubernetes:Service `` so that it will create a Kubernetes service, which will expose the Ballerina service that is running on a Pod.
- In addition we have used `` @kubernetes:Ingress ``, which is the external interface to access your service (with path `` /`` and host name ``ballerina.guides.io``)

If you are using Minikube, you need to set a couple of additional attributes to the `@kubernetes:Deployment` annotation.
- `dockerCertPath` - The path to the certificates directory of Minikube (e.g., `/home/ballerina/.minikube/certs`).
- `dockerHost` - The host for the running cluster (e.g., `tcp://192.168.99.100:2376`). The IP address of the cluster can be found by running the `minikube ip` command.

- Now you can build a Ballerina executable archive (.balx) of the service that we developed above, using the following command. This will also create the corresponding Docker image and the Kubernetes artifacts using the Kubernetes annotations that you have configured above.

```
   $ ballerina build mobile-bff

   Output: 
     Run following command to deploy kubernetes artifacts: 
     kubectl apply -f ./target/kubernetes/mobile-bff
```

```
   $ ballerina build desktop-bff

   Output:
     Run following command to deploy kubernetes artifacts:
     kubectl apply -f ./target/kubernetes/desktop-bff
```

- You can verify that the Docker image that we specified in `` @kubernetes:Deployment `` is created, by using `` docker images ``.
- Also the Kubernetes artifacts related our service, will be generated under `` ./target/kubernetes``.
- Now you can create the Kubernetes deployment using:

```bash
   $ kubectl apply -f ./target/kubernetes/mobile-bff

   Output: 

   deployment.extensions "ballerina-guides-mobile-bff-service" configured
   ingress.extensions "ballerina-guides-mobile-bff-service" configured
   service "ballerina-guides-mobile-bff-service" configured
```

```bash
   $ kubectl apply -f ./target/kubernetes/desktop-bff

   Output: 

   deployment.extensions "ballerina-guides-desktop-bff-service" configured
   ingress.extensions "ballerina-guides-desktop-bff-service" configured
   service "ballerina-guides-desktop-bff-service" configured
```

- You can verify Kubernetes deployment, service and ingress are running properly, by using following Kubernetes commands.

```bash
   $ kubectl get service
   $ kubectl get deploy
   $ kubectl get pods
   $ kubectl get ingress
```

- If everything is successfully deployed, you can invoke the service either via Node port or ingress.

Node Port:
```bash
   $ curl -v -X GET http://localhost:<Node_Port>/mobile-bff/profile
```
```bash
   $ curl -v -X GET http://localhost:<Node_Port>/desktop-bff/alerts
```

If you are using Minikube, you should use the IP address of the Minikube cluster obtained by running the `minikube ip` command. The port should be the node port given when running the `kubectl get services` command.

Ingress:

Add `/etc/hosts` entry to match hostname. For Minikube, the IP address should be the IP address of the cluster.
```
   127.0.0.1 ballerina.guides.io
```

Access the service
```bash
   $ curl -v -X GET http://ballerina.guides.io/mobile-bff/profile
```

```bash
   $ curl -v -X GET http://ballerina.guides.io/desktop-bff/alerts
```
