# Backend For Frontend

Backends For Frontends is a Microservice design pattern and core idea is to define different backend for each kind of front-end[1][2]. This will allow  each type of user experience to have separate backend API layer (shim). The design pattern has its own advantages and disadvantages and you have to use the design pattern by looking at the requirements properly[1][2]. 

> In this guide you will learn about using  Backend For Frontend design pattern with Ballerina.

The following are the sections available in this guide.

- [What you'll build](#what-youll-build)
- [Prerequisites](#prerequisites)
- [Implementation](#implementation)
- [Testing](#testing)
- [Deployment](#deployment)
- [Observability](#observability)

## What you’ll build
To understand how BFF works lets take a real world use case of online health care management system. A health care provider have a Desktop Application and a Mobile Application for their users to have better online experience. Once the user login to the Desktop application the home page information shown in Desktop application and Mobile application may vary. Specially the resource limitations in mobile device such as screen size, battery life and data usage cause the mobile application to show minimal viable information to the end user. So the design of the application is suppose to have two different BFFs to support each user experience. Following is the design of the BFF, here the BFF is not implementing anything new, instead it consumes existing downstream services and act as a shim to translate the required information for each user experience. Following diagram demonstrates the use case with two BFF models. 

// image here 

In this use case we have two applications called Desktop Application and Mobile Application. For each application there is specific backend service (BFF) called Desktop BFF and Mobile BFF respectively. These BFFs consumes set of downstream services called Appointment Management Service, Medical Record Service, Notification Management Service and Message Management Service. For the purpose of the demonstration Ballerina is used to build both BFF layer and downstream service layer. 

## Prerequisites

- [Ballerina Distribution](https://ballerina.io/learn/getting-started/)
- A Text Editor or an IDE

### Optional requirements
- Ballerina IDE plugins ([IntelliJ IDEA](https://plugins.jetbrains.com/plugin/9520-ballerina), [VSCode](https://marketplace.visualstudio.com/items?itemName=WSO2.Ballerina), [Atom](https://atom.io/packages/language-ballerina))
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
      └── desktop-bff
          ├── desktop_bff_service.bal
          └── tests
              └── desktop_bff_service_test.bal
```
