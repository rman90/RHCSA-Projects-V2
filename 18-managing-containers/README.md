# 18 – Managing Containers with Podman

Beyond building images, administrators must run, inspect and manage containers effectively.  This module introduces advanced Podman commands and concepts such as pods, health checks and resource limits.

## Listing and inspecting containers

| Command | Description |
|-------:|-------------|
| `podman ps` | List running containers.  Use `-a` to include stopped containers. |
| `podman inspect <name-or-id>` | Return detailed JSON describing a container or image (configuration, mounts, networks, etc.). |
| `podman top <name-or-id>` | Show processes running inside a container. |
| `podman logs <name-or-id>` | View a container’s stdout/stderr output. |
| `podman stats` | Live stream of resource usage for containers. |
| `podman pause`/`podman unpause` | Temporarily suspend or resume all processes in a container. |

## Pods and networks

Pods group one or more containers that share a network namespace.  This is useful when multiple containers need to communicate over localhost, such as a web server and a sidecar:

```bash
podman pod create --name mypod -p 8080:80
podman run -dt --pod mypod --name webserver nginx:alpine
podman run -dt --pod mypod --name logcollector busybox tail -f /var/log/nginx/access.log
```

All containers in a pod share the same IP and port mappings.  Use `podman pod ps` and `podman pod inspect` to manage pods.

## Health checks and restart policies

Podman can monitor container health via custom commands.  Define a health check in a Containerfile or at run time:

```bash
podman run -d --name db \
  --health-cmd="pg_isready -U postgres" \
  --health-interval=30s \
  postgres:15
podman healthcheck run db
```

Restart policies dictate what happens when a container exits:

| Policy | Description |
|--------|-------------|
| `no` | Never restart (default). |
| `on-failure[:max]` | Restart only on non‑zero exit code. |
| `always` | Always restart the container when it exits. |
| `unless-stopped` | Like `always` but not on manual stop. |

Example:

```bash
podman run -d --name myapp --restart=on-failure:3 myimage
```

## Resource limits

Limit CPU and memory usage to prevent containers from consuming all system resources:

```bash
podman run -d --cpus=1.5 --memory=512m myimage
```

## Projects

- Write a Podman `pod` with a web application and a logging sidecar.
- Experiment with `podman stats` to monitor container CPU and memory usage.
- Create a container with a failing health check and observe Podman’s handling.