#!/bin/sh
id=$(buildah from --pull docker.io/octobus/heptapod-runner:latest)
buildah config --annotation vc $id
buildah config --author='Richard Westhaver' $id
buildah config --volume /stash $id
buildah config --volume /store $id
buildah run --net host -v /mnt/y/data/private/gitlab-runner/:/etc/gitlab-runner $id gitlab-runner register 
buildah commit $id heptapod-runner
