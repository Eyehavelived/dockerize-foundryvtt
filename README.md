# dockerize-foundryvtt

I had originally created this as a guide for dockerizing foundryVTT and deploying it onto Google Kubernetes Engine (GKE). Unfortunately, that plan was scrapped when I did actually deploy it but I was billed $11 for having it active for 2 days doing nothing beisdes asking me to enter my license.

I'm leaving the steps here for building the image and running the container on Docker Desktop.

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

3. Navigate to the nginx_proxy folder and build the custom nginx image
```docker build -t my-custom-nginx .```

4. Then run the container on the same network earlier.
```docker run -d --name nginx-proxy   -p 80:80   --network foundry_network   my-custom-nginx```

# Creating additional instances 

Maybe you're like me and you want to run multiple worlds/campaigns concurrently. I've had mine set up so that campaigns and one-shots have their own instances and URLs, giving me and my players the ability to use and update content within the one-shot without impacting the campaign.

I encountered a few inconveniences setting this up, so the solutions here aren't ideal, but they did get the job done. I would love to know what would've been a better way of doing them though!

## Separate port

Your device can't have multiple applications running and listening to the same port, so your second instance will have to be on a different port. Initially I had tried to do this by editing the `commons.js` and `config.mjs` files in the FoundryVTT-X.Y folder, but it turned out that it had no impact on the images I built as they still ran on 30000.

In the end, what I did was 
1. momentarily shut down the first instance of Foundry
2. ran the second instance on 30000
3. entered the license number, changed the port settings to 29999, saved
4. stopped the second instance of foundry
5. restart the second instance on 29999
6. restart the first instance on 30000
7. restart nginx 

## Separate Volumes

Unfortunately, you can't have both containers having write-access to the same persistent volumes - meaning that Docker doesn't have built-in strategies for locking the volumes for writing. For a quick and simple solution, I've created a separate volume for each container, though in future I'll be looking into how to give each container read-only access to each other's volumes so that players can use/copy data that is already present in the other volume.

## Container must be running for docker resolver

If you have two servers defined in your nginx file, each with proxy_pass pointing to a different container name, you'll need the containers to be running before you run the container, otherwise it fails and stops. It doesn't seem to complain as much if you run the nginx container and then stop one of the containers though (you'll get a Gateway Error for that container but the other one directs fine).
