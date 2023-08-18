#!/usr/bin/env bash

# @description remove ansi codes from input or files given as argument
# @arg $@ files:String[] the files to filter
# @exitcode * if one of the filter command fails
# @stdin you can use stdin as alternative to files argument
# @stdout the filtered content
# @see https://en.wikipedia.org/wiki/ANSI_escape_code
# shellcheck disable=SC2120
Filters::removeAnsiCodes() {
  # cspell:disable
  sed -E 's/\x1b\[[0-9;]*[mGKHF]//g' "$@"
  # cspell:enable
}
