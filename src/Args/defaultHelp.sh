#!/usr/bin/env bash

Args::defaultHelp() {
  local helpArg=$1
  shift || true
  if ! Args::defaultHelpNoExit "${helpArg}" "$@"; then
    exit 0
  fi
}
