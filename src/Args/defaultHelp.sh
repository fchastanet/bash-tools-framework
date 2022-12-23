#!/usr/bin/env bash

Args::defaultHelp() {
  if ! Args::defaultHelpNoExit "$@"; then
    exit 0
  fi
}
