# dockerize-foundryvtt

I had originally created this as a guide for dockerizing foundryVTT and deploying it onto Google Kubernetes Engine (GKE). Unfortunately, that plan was scrapped when I did actually deploy it but I was billed $11 for having it active for 2 days doing nothing beisdes asking me to enter my license.

I'm leaving the steps here for building the image and running the container on Docker Desktop.

## Why use Docker?

Granted, Foundry is pretty lightweight as a NodeJS application, and given that you'd have just over a handful of people accessing the application at the same time, it doesn't really need much in terms of scaling. But something an interviewer told me about Dockerizing got me thinking - once of the benefits of dockerizing and running containers is that you can scale horizontally by running multiple instances of a container ye? Well, what do we have on Foundry that it would be really nice if you could run concurrently? _Worlds_. We could run multiple worlds and have them store the world data on the same persistent volumes without having to hit the `Return to Setup` button in the Settings page.

## Things to Install

### NodeJS

The version of Foundry that is made for server deployment is a NodeJS application, so make sure you have [NodeJS installed](https://nodejs.org/en/download) on your machine, so you can at least check that it's running correctly. 

### Docker

Obviously you'll need [Docker](https://www.docker.com/products/docker-desktop/) installed for dockerizing your Foundry application.

### Rancher

If not Docker, you can use [Rancher](https://rancherdesktop.io/)

## Additional things you'll need

### The FoundryVTT application zip file

You can find this on FoundryVTT's page > Profile > Purchased Licenses
Set the Operating System to `Linux/NodeJS` before downloading.

NOTE: At the time of this guide, the latest FoundryVTT version was 11.315, so take note to update any references to `FoundryVTT-11.315` with the lastest version for you.

## Building the Image

Unzip the downloaded file and into the same folder as the Dockerfile I have here.

### Build the Image
From the directory containing your Dockerfile and FoundryVTT.zip, run the following command to build your Docker image. Replace myfoundryvtt with the name you want to give your image:
```docker build -t myfoundryvtt .```

### Run your container
After building the image, you can start a container from it. The following command starts a container in detached mode, maps port 30000 on the host to port 30000 in the container, and ensures data persistence through a named volume (foundryvtt_data):
```docker run -d -p 30000:30000 -v foundryvtt_data:/dockerize_foundryvtt/data --name myfoundryvtt_container myfoundryvtt```

# Setting up a URL for the server with path to different instances/worlds

For setting up the URL for the server, I used nginx to make a reverse DNS proxy. Since we have multiple containers going on at the same time, we'll want them to exist on the same network.

1. Create the network that they will be sharing.
```docker network create foundry_network```

2. Rerun the Foundry image with this new network
```docker run -d -p 30000:30000 -v foundryvtt_data:/dockerize_foundryvtt/data --network foundry_network --name myfoundryvtt_container myfoundryvtt```

3. Inspect the network you've created to get the `IPv4Address` of the foundry instance under the `Containers` values
```docker network inspect foundry_network```

It'll look something like this:
```
"Containers": {
    "9c130b12f9c41be8b29c0a88c22de67019235363b8a406bd6e81c2bbaf792a6e": {
        "Name": "myfoundryvtt_container",
        "EndpointID": "92ef584986ec4ae6a628d0bc76c977b0d5b80bb9c0e35c0c90633574f43d4b7d",
        "MacAddress": "02:42:ac:12:00:02",
        "IPv4Address": "172.18.0.2/16",
        "IPv6Address": ""
    },
```
In this case, Foundry's address is `172.18.0.2`. Use this to update the `nginx.conf`, replacing the IP address in it.

Navigate to the nginx_proxy folder and build the custom nginx image
```docker build -t my-custom-nginx .```

Then run the container on the same network earlier.
```docker run -d --name nginx-proxy   -p 80:80   --network foundry_network   my-custom-nginx```
