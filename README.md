# Backend For Frontend 

Backends For Frontends is a Microservice design pattern which is useful to avoid customizing single monolithic backend API to support multiple user experiences. Core idea is to define different backend for each kind of front-end[1][2]. 

> In this guide you will learn about using  Backend For Frontend design pattern with Ballerina. 

## What you’ll build
To understand how BFF works lets take a real world use case of online health care management system. A health care provider have a Desktop Application and a Mobile Application for their users to have better online experience. Once the user login to the Desktop application the home page information shown in Desktop application and Mobile application may vary. Specially the resource limitations in mobile device such as screen size, battery life and data usage cause the mobile application to show minimal viable information to the end user. So the design of the application is suppose to have two different BFF’s to support each user experience. Following is the design of the BFF, here the BFF is not implementing anything new, instead it consumes existing core services and act as a shim to translate the required information for each user experience.
