#!/usr/bin/env bash

# @description Compute a cache from wslpath options
# @arg $@ args:String[] arguments passed to wslpath
# @stderr diagnostics information is displayed
# @stdout the cache key deduced from the options
# @require Linux::Wsl::requireWsl
# @feature cache
# @internal
Linux::Wsl::getKeyFromWslpathOptions() {
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
