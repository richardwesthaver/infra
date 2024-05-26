#!/bin/sh
set -e
img="${1:-localhost/box}"
rule="${2:-sbcl-build}"
cmd="cd infra; skel pull ; skel make clean $rule"
podman run --name "$rule" --replace -it "$img" -c "$cmd"
podman cp --overwrite $rule:infra/.stash .
