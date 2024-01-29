#!/bin/sh
set -e
podman manifest create infra/alpine
podman build -f Containerfile.alpine --squash --platform linux/amd64,linux/arm64 --manifest infra/alpine -t infra/alpine
podman manifest push infra/alpine registry.compiler.company/comp/infra/alpine

podman build -f Containerfile.archarm --squash -t infra/archarm
podman push infra/archarm registry.compiler.company/comp/infra/archarm

podman manifest create infra/archlinux
podman build -f Containerfile.archriscv --squash -t infra/archriscv --platform linux/riscv64 --manifest infra/archlinux
podman build -f Containerfile.archarm --squash -t infra/archarm --platform linux/arm64 --manifest infra/archlinux
podman build -f Containerfile.archlinux --squash -t infra/archlinux --platform linux/amd64 --manifest infra/archlinux
podman manifest push infra/archlinux registry.compiler.company/comp/infra/archlinux

podman build -f Containerfile.box --squash -t infra/box
podman push infra/box registry.compiler.company/comp/infra/box

podman build -f Containerfile.ubuntu --squash -t infra/ubuntu
podman push infra/ubuntu registry.compiler.company/comp/infra/ubuntu

podman build -f Containerfile.worker --squash -t infra/worker
podman push infra/worker registry.compiler.company/comp/infra/worker

podman build -f Containerfile.operator --squash -t infra/operator
podman push infra/operator registry.compiler.company/comp/infra/operator

# podman build -f Containerfile.vc-runner --squash -t infra/vc-runner
# podman push infra/vc-runner registry.compiler.company/comp/infra/vc-runner

# podman build -f Containerfile.vc --squash -t infra/vc
# podman push infra/vc registry.compiler.company/comp/infra/vc
