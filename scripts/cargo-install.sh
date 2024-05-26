#!/usr/bin/env bash
cargo install --path "${1}" --root "${2:-.stash/src/rust}"
