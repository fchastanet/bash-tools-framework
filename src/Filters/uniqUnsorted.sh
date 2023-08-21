#!/usr/bin/env bash
# shellcheck disable=SC2120

# @description uniq command need input file to be sorted
# here We are using awk that do not need file to be sorted
# to get uniq values
# @exitcode * if one of the filter command fails
# @stdin you can use stdin as alternative to str argument
# @stdout the filtered content
# shellcheck disable=SC2120
Filters::uniqUnsorted() {
  awk '!line[$0]++' "$@"
}
