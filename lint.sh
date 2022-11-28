#!/bin/bash
time npx mega-linter-runner \
  -e HOST_USER_ID="$(id -u)" \
  -e HOST_GROUP_ID="$(id -g)" \
  --flavor javascript \
  "$@"
