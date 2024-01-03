#!/usr/bin/env bash
podman pod create --name ci --restart=always --infra-name=ci-operator -l=operator
