#!/bin/sh
set -e
podman run --name "box" --replace -it "infra/box" $@
