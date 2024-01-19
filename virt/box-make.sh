#!/bin/sh
set -e
img="${1:-localhost/infra/box}"
rule="${2:-sbcl-build}"
# in nushell
cmd="cd /usr/local/src/infra; make clean $rule"
podman run --name "$rule" --replace -it "$img" $cmd
podman cp "$rule:/usr/local/src/infra/dist/." .
