# Use a base image with Node.js (Foundry VTT is a Node.js application)
FROM node:18

# Set the working directory in the container
WORKDIR /foundryvtt

# Copy the FoundryVTT zip into the container
COPY FoundryVTT-11.315.zip /foundryvtt

# install nodejs
# RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash &&\
#     export NVM_DIR="$HOME/.nvm" &&\
#     . ~/.bashrc &&\
#     nvm install 18 &&\
#     nvm use 18

# Install unzip
RUN apt-get update && \
    apt-get install -y unzip && \
    unzip FoundryVTT-11.315.zip && \
    rm FoundryVTT-11.315.zip

# Expose the port Foundry VTT runs on
EXPOSE 30000

# Set the volume for configuration and data persistence
VOLUME /foundryvtt/Data

# Start Foundry VTT
CMD ["node", "resources/app/main.js", "--dataPath=/foundryvtt/Data"]
