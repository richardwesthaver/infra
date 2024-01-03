#!/usr/bin/env bash
podman pod create --name ci --restart=always --infra-image=ci-operator --infra-name=ci-operator -l=operator --publish 6000:6000
