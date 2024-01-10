#!/bin/sh
# podman create --name vc-main --replace --publish 2222:22/tcp --publish 8888:80/tcp vc
podman start vc-main
podman exec vc-main gitlab-ctl hup hgserve
