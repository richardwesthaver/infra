#!/bin/sh
ARGS="--name ${1:-vc-r0} --replace -v /mnt/y/data/private/gitlab-runner:/etc/gitlab-runner -dt heptapod-runner"
podman container run $ARGS
