# dockerize-foundryvtt

I had originally created this as a guide for dockerizing foundryVTT and deploying it onto Google Kubernetes Engine (GKE). Unfortunately, that plan was scrapped when I did actually deploy it but I was billed $11 for having it active for 2 days doing nothing beisdes asking me to enter my license.

I'm leaving the steps here for building the image and running the container on Docker Desktop and Rancher Desktop (because it occured to me that I could maybe have my Mid-2011 MacBook Pro run the container as an always-on server)

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

