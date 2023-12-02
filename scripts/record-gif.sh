#!/usr/bin/bash
# Wrapper for t-rec program
WINDOWID="${1}" t-rec -b transparent -qn -s 800ms -e 800ms --output "${2:-$(date +%s)}"
