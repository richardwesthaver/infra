#!/bin/sh
set -e
podman build -f Containerfile.alpine --squash --platform linux/amd64 -t comp/infra/alpine
# podman build -f Containerfile.alpine --squash --platform linux/arm64 --manifest comp/infra/alpine -t comp/infra/alpine

# podman build -f Containerfile.archriscv --squash -t infra/archriscv --platform linux/riscv64 --manifest infra/archlinux
# podman build -f Containerfile.archarm --squash -t infra/archarm --platform linux/arm64 --manifest infra/archlinux
podman build -f Containerfile.archlinux --squash --platform linux/amd64 -t comp/infra/archlinux

podman build -f Containerfile.box --squash -t comp/infra/box

podman build -f Containerfile.ubuntu --squash -t comp/infra/ubuntu

podman build -f Containerfile.worker --squash -t comp/infra/worker

podman build -f Containerfile.operator --squash -t comp/infra/operator

# podman build -f Containerfile.vc-runner --squash -t infra/vc-runner
# podman push infra/vc-runner registry.compiler.company/comp/infra/vc-runner

# podman build -f Containerfile.vc --squash -t infra/vc
# podman push infra/vc registry.compiler.company/comp/infra/vc
