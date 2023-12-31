#!/usr/bin/env bash
# tcp://localhost:4282
podman system service --time=0 unix:///run/user/$UID/podman.sock # --cors
