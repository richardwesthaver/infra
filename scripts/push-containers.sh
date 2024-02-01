#!/bin/sh
set -e
podman push comp/infra/alpine registry.compiler.company/comp/infra/alpine
podman push comp/infra/archlinux registry.compiler.company/comp/infra/archlinux
podman push comp/infra/box registry.compiler.company/comp/infra/box
podman push comp/infra/ubuntu registry.compiler.company/comp/infra/ubuntu
podman push comp/infra/worker registry.compiler.company/comp/infra/worker
podman push comp/infra/operator registry.compiler.company/comp/infra/operator

