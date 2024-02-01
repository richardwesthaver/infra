#!/bin/sh
set -e
podman pull registry.compiler.company/comp/infra/alpine
podman pull registry.compiler.company/comp/infra/archlinux
podman pull registry.compiler.company/comp/infra/box
podman pull registry.compiler.company/comp/infra/ubuntu
podman pull registry.compiler.company/comp/infra/worker
podman pull registry.compiler.company/comp/infra/operator
