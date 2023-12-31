#!/bin/sh

# to run a container in the pod:
# podman run -dt --pod comp box-base top
# podman container attach --latest
# sudo podman ps -ap
NAME=${1:-comp}
podman pod create --name $NAME --replace
