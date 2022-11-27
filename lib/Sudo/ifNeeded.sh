#!/usr/bin/env bash

Sudo::ifNeeded() {
  if [[ "$(id -u)" = "0" ]]; then
    "$@"
  else
    sudo "$@"
  fi
}
