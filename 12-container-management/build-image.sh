#!/bin/bash
#
# RHCSA: Build and Run Custom Container Image
# This script assumes you have written a Containerfile and an index.html in the current
# directory (see custom-containerfile.md).  It builds the image, runs a container and
# demonstrates mounting a host directory for persistent storage.

set -euo pipefail

IMAGE_NAME=${1:-mywebimage:latest}
CONTAINER_NAME=${2:-myweb}

echo "[+] Building image $IMAGE_NAME..."
podman build -t "$IMAGE_NAME" .

echo "[+] Running container $CONTAINER_NAME on host port 8080"
podman run --name "$CONTAINER_NAME" -p 8080:8080 -d "$IMAGE_NAME"

echo "[+] Container is running.  Visit http://localhost:8080 to see your page."
echo "Press any key to stop the container..."
read -n1 -s

echo "[+] Stopping and removing container"
podman stop "$CONTAINER_NAME"
podman rm "$CONTAINER_NAME"

echo "[✓] Done"