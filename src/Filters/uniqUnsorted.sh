#!/usr/bin/env bash
# shellcheck disable=SC2120

# @description uniq command need input file to be sorted
# here We are using awk that do not need file to be sorted
# to get uniq values
# iterates over each file and prints (default awk behavior)
# each unique line; only takes first value and ignores duplicates
# Note ! be careful of memory usage as each unique $0 is stored in an array
# @exitcode * if one of the filter command fails
# @stdin you can use stdin as alternative to str argument
# @stdout the filtered content
# shellcheck disable=SC2120
Filters::uniqUnsorted() {
  awk '!seen[$0]++' "$@"
}
