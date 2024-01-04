#!/bin/sh
podman container run --name "${1:-ci-w0}" --replace -dt ci-worker sbcl
