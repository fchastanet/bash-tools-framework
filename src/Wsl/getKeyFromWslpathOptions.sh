#!/usr/bin/env bash

Wsl::getKeyFromWslpathOptions() {
  local options
  options=$(getopt -o "auwm" -- "$@" 2>/dev/null) || {
    Log::displayError "invalid options specified"
    return 1
  }
  local key="wslpath"
  eval set -- "${options}"
  while true; do
    case "$1" in
      -a | -u | -w | -m)
        key="${key}$1"
        ;;
      --)
        shift || true
        break
        ;;
      *)
        shift || true
        Log::displayWarning "Unknown key $1"
        ;;
    esac
    shift || true
  done
  echo -E "${key}_$1"
}
