#!/usr/bin/env bash

# @description convert text to lower case
# @arg $1 str:String the string to filter
# @exitcode * if one of the filter command fails
# @stdin you can use stdin as alternative to str argument
# @stdout the filtered content
# shellcheck disable=SC2120
Filters::toLowerCase() {
  if (($# == 1)); then
    Filters::toLowerCase <<<"$1"
  else
    tr '[:upper:]' '[:lower:]'
  fi
}
