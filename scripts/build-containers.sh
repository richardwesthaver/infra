#!/bin/sh
set -e
podman manifest create infra/alpine
podman build -f Containerfile.alpine --platform linux/amd64,linux/arm64 --manifest infra/alpine
podman manifest push infra/alpine registry.compiler.company/comp/infra/alpine
