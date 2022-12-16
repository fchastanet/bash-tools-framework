#!/usr/bin/env bash

Args::defaultHelpNoExit() {
  local helpArg="$1"
  shift || true
  # shellcheck disable=SC2034
  local args
  args="$(getopt -l help -o h -- "$@" 2>/dev/null)" || true
  eval set -- "${args}"

  while true; do
    case $1 in
      -h | --help)
        Args::showHelp "${helpArg}"
        return 1
        ;;
      --)
        break
        ;;
      *)
        # ignore
        ;;
    esac
  done
}
