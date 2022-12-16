#!/usr/bin/env bash

Args::defaultHelp() {
  local helpArg="$1"
  shift || true
  # shellcheck disable=SC2034
  local args
  args="$(getopt -l help -o h -- "$@" 2>/dev/null)" || true
  eval set -- "${args}"

  while true; do
    case $1 in
      -h | --help)
        echo -e "${helpArg}"
        exit 0
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
