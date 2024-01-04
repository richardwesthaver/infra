#!/bin/sh
ARGS="--name ${1:-ci-op} --replace -dt ci-operator ${2:-bash}"
podman container run $ARGS
       
