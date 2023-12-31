#!/bin/sh
BOX="${1:-demo}"
NAME="${2:-demo0}"
podman run --name $NAME -dt localhost/$BOX 
