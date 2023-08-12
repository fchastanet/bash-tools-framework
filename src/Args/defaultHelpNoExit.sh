#!/usr/bin/env bash

# @description display help if one of args is -h|--help
# @arg $1 helpArg:String|Function the help string to display or the function to call to display the help
# @arg $@ args:String[] list of options
# @option -h short help option
# @option --help long help option
# @exitcode 1 displays help and returns with code 1 if -h or --help option is in the args list
# @output displays help if -h or --help option is in the args list
Args::defaultHelpNoExit() {
  local helpArg=$1
  shift || true
  # shellcheck disable=SC2034
  local args
  args="$(getopt -l help -o h -- "$@" 2>/dev/null)" || true
  eval set -- "${args}"

  while true; do
    case $1 in
      -h | --help)
        if [[ "$(type -t "${helpArg}")" = "function" ]]; then
          "${helpArg}" "$@"
        else
          Args::showHelp "${helpArg}"
        fi
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
