#!/usr/bin/env bash

# @description Find all EMBED directives
# @arg $1 file:String (optional) file to filter (optional as file can be piped to this function)
# @stdin this command supports filter on stdin piped to grep or via file argument passed to grep
# @exitcode 2 if an error occurred during grep
Embed::filter() {
  grep -E -e "^# EMBED (.+) (AS|as|As) (.+)$" "$@" || test $? = 1
}
