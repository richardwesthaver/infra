#!/bin/sh
ports="${1:-8080:80/tcp}"
podman run -dt -p $ports localhost/archlinux-base
