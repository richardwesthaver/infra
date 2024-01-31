#!/bin/sh

# SHELL=nu
set -e
img="${1:-infra/box}"
rule="${2:-sbcl-build}"
# in nushell
cmd="cd infra; hg pull -u; make build clean dist $rule"
podman run --name "$rule" --replace -it "$img" -c "$cmd"
podman cp --overwrite $rule:infra/dist .
podman cp --overwrite $rule:infra/build .
