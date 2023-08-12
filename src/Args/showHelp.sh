#!/usr/bin/env bash

# @description display help
# @arg $1 helpArg:String the help string to show
# @output display help arg
Args::showHelp() {
  local helpArg="$1"
  echo -e "${helpArg}"
}
