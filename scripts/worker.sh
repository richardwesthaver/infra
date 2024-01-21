#!/bin/sh
set -e
name="${1:-worker}"
podman run --name "$name" --replace --net=pasta -dt infra/worker ${@:2}
