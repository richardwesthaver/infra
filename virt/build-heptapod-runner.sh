#!/bin/sh
id=$(buildah from --pull docker.io/octobus/heptapod-runner:latest)
buildah config --annotation heptapod $id
buildah config --author='Richard Westhaver' $id
buildah commit $id heptapod-runner
