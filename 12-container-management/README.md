# 📁 12 – Container Management with Podman

Containers provide isolated environments to run applications.  Unlike virtual machines, containers share the host kernel and are lightweight.  Red Hat uses **Podman** as its container engine in place of Docker.

## Podman basics

| Command | Description |
|-------:|-------------|
| `podman search nginx` | Search the registry for images matching `nginx`. |
| `podman pull registry.redhat.io/rhel9/httpd-24` | Pull an image from a registry.  Use `--authfile` for Red Hat registries. |
| `podman images` | List local images. |
| `podman run --rm -it registry.fedoraproject.org/fedora:latest bash` | Start a container, attach an interactive shell, remove it when finished. |
| `podman ps` / `podman ps -a` | Show running/all containers. |
| `podman stop <container>` | Stop a running container. |
| `podman rm <container>` | Remove a stopped container. |
| `podman inspect <container>` | Show detailed configuration and runtime information. |
| `podman system prune` | Remove unused images, containers and networks. |

Podman is daemonless; each command talks directly to the container runtime.  Use `--network host` to share the host’s network stack, and `--volume hostdir:containerdir` to mount persistent storage.

## Rootless vs rootful

Podman can run as a regular user (rootless).  Rootless containers are isolated using user namespaces and cannot bind to low ports (<1024) without `setcap`.  Running as root allows more privileges but is less secure.  The command syntax is the same either way.

## Systemd integration

Podman can generate systemd unit files to manage containers like services:

```bash
podman generate systemd --name mycontainer --files --new > ~/.config/systemd/user/mycontainer.service
systemctl --user daemon-reload
systemctl --user enable --now mycontainer.service
```

The service will automatically start your container on boot and restart it if it exits.

## Projects

- **custom-containerfile.md** – Explains how to write a simple Containerfile and build an image with Podman.
- **build-image.sh** – Builds the custom image, runs a container and demonstrates volume mounting.