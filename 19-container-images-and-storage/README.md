# 📁 19 – Container Images and Persistent Storage

This module digs deeper into building images and persisting data across container restarts.

## Building images

Building images with Podman uses a Containerfile.  See the `custom-containerfile.md` in Module 12 for step‑by‑step instructions.  Key guidelines:

- Use official base images (e.g. `ubi9/ubi`, `ubi9/httpd-24`).  Keep base images up to date by rebuilding periodically.
- Use `COPY` rather than `ADD` unless you need archive extraction or remote file fetching.
- Combine commands wisely to reduce layers; however readability is more important than micro‑optimisation.
- Always specify an explicit `CMD` or `ENTRYPOINT` so the container knows what to run.
- Document the image with `LABEL` metadata.

## Persistent volumes

Containers are stateless by default; changes inside are lost when the container exits.  To persist data, mount host directories or named volumes into the container:

```bash
# Bind mount host directory into container
podman run -d -v /srv/data:/data:z mydatabase

# Create a named volume and mount it
podman volume create dbdata
podman run -d -v dbdata:/var/lib/mysql:z mariadb
```

The `:z` suffix sets SELinux context on the mount appropriately for shared content.  Use `podman volume inspect <name>` to find a volume’s location on the host.

## Layer storage

Podman stores container layers under `/var/lib/containers/storage` (or `~/.local/share/containers/storage` for rootless).  Monitor disk usage here and prune unused objects:

```bash
podman system df            # space used by images, containers and volumes
podman system prune         # remove unused objects
```

## Projects

- Create a simple database container mounting data from a host directory, then verify that data persists after stopping and removing the container.
- Inspect the image history of your custom web image using `podman history mywebimage` to see each layer’s origin.