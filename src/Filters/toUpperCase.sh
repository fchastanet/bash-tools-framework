#!/usr/bin/env bash
# shellcheck disable=SC2120

# @description convert text to upper case
# @arg $1 str:String the string to filter
# @exitcode * if one of the filter command fails
# @stdin you can use stdin as alternative to str argument
# @stdout the filtered content
# shellcheck disable=SC2120
Filters::toUpperCase() {
  if (($# == 1)); then
    Filters::toUpperCase <<<"$1"
  else
    tr '[:lower:]' '[:upper:]'
  fi
}
