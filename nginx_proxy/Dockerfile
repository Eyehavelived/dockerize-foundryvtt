# Use the official Nginx image as the base
FROM nginx:latest

# Remove the default Nginx configuration file
RUN rm /etc/nginx/conf.d/default.conf

# Copy a new configuration file from your file system into the container
COPY nginx.conf /etc/nginx/conf.d

# Optionally, copy other resources into the container
# COPY static-html-directory /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx when the container has provisioned
CMD ["nginx", "-g", "daemon off;"]
