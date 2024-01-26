#!/bin/sh
# replay terminal session from typescript and timing files.
set -e
name="${1:-typescript}"
log="${2:-$name.log}"
scriptreplay --timing=$log $name
