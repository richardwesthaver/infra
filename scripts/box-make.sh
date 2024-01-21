#!/bin/sh
set -e
img="${1:-infra/box}"
rule="${2:-sbcl-build}"
# in nushell
cmd="cd /usr/local/src/infra; hg pull -u; make clean $rule"
podman run --name "$rule" --replace -it "$img" -e "$cmd"
make dist
podman cp --overwrite $rule:/usr/local/src/infra/dist .
