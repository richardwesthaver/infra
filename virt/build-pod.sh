#!/bin/sh
podman pod create --name comp.lab --infra --publish 8080:80 --network bridge
