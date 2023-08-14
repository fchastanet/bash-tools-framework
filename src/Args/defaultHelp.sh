#!/usr/bin/env bash

# @description display help and exits if one of args is -h|--help
# @arg $1 helpArg:String|Function the help string to display or the function to call to display the help
# @arg $@ args:String[] list of options
# @option -h short help option
# @option --help long help option
# @exitcode 0 displays help and exit with code 0 if -h or --help option is in the args list
# @stdout displays help if -h or --help option is in the args list
Args::defaultHelp() {
  local helpArg=$1
  shift || true
  if ! Args::defaultHelpNoExit "${helpArg}" "$@"; then
    exit 0
  fi
}
