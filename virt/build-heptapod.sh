#!/bin/sh
id=$(buildah from --pull docker.io/octobus/heptapod:latest)
buildah config --annotation vc $id
buildah config --author='Richard Westhaver' $id
buildah commit $id heptapod
