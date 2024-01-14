#!/bin/sh
# podman create --name "${1:-vc-r0}" --replace -P -it heptapod-runner
podman start '${1:-vc-r0}'
