#!/bin/sh
set -e
podman run --name operator --replace -it "infra/operator" $@
