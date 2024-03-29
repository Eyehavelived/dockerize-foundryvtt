# Start from a base image for NodeJS 18
FROM node:18

# Your application's Dockerfile commands here
# For example, setting the working directory:
WORKDIR /dockerize_foundryvtt

RUN mkdir foundryvtt

# Copy the FoundryVTT zip into the container
COPY /FoundryVTT-11.315/. /dockerize_foundryvtt/foundryvtt

# Expose the port Foundry VTT runs on
EXPOSE 30000

# Set the volume for configuration and data persistence
# FoundryVTT doesnt like it when the data folder is in the same directory as the application
VOLUME /dockerize_foundryvtt/data

# Start Foundry VTT
CMD ["node", "foundryvtt/resources/app/main.js", "--dataPath=/dockerize_foundryvtt/data"]
