#!/bin/sh
box="$1:-demo"
ports="${2:-8080:80/tcp 9090:9090/udp}"
podman run -dt -p $ports localhost/$box
