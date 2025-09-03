# Creating a Custom Container Image

This guide walks through building a simple container image using Podman and a `Containerfile` (also known as a `Dockerfile`).  You will create an image that serves a static HTML page using the Apache HTTP server.

## 1. Create a working directory

Choose a directory to hold your build context and create the files:

```bash
mkdir -p ~/podman-webdemo
cd ~/podman-webdemo
```

## 2. Write the Containerfile

Create a file named `Containerfile` with the following contents:

```Containerfile
FROM registry.redhat.io/ubi9/httpd-24

LABEL maintainer="you@example.com"

# Copy website files into the document root
COPY index.html /var/www/html/index.html

# Expose the HTTP port
EXPOSE 8080

# Configure Apache to listen on port 8080
RUN echo "Listen 8080" > /etc/httpd/conf.d/listen.conf

CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
```

This file starts from the UBI9 Apache image, sets a maintainer label, copies in your website, exposes port 8080 and tells Apache to listen on that port.  The final `CMD` keeps the HTTP server running in the foreground.

## 3. Add content

Create an `index.html` in the same directory:

```html
<!DOCTYPE html>
<html lang="en">
<head><meta charset="UTF-8"><title>Podman Demo</title></head>
<body><h1>Welcome to your custom Podman container!</h1></body>
</html>
```

## 4. Build the image

From within the `~/podman-webdemo` directory run:

```bash
podman build -t mywebimage:latest .
```

This reads the `Containerfile`, downloads the base image (if necessary) and creates a new image named `mywebimage`.

## 5. Run the container

Start a container from your new image, publishing port 8080 on the host:

```bash
podman run --name myweb -p 8080:8080 -d mywebimage
```

Visit `http://localhost:8080/` in your browser to see the page.  When finished, stop and remove the container:

```bash
podman stop myweb
podman rm myweb
```

## 6. Clean up

To remove the image when you no longer need it:

```bash
podman rmi mywebimage
```

You have successfully created and run a custom container image!