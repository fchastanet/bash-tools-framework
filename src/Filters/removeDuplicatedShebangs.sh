#!/usr/bin/env bash

# @description remove all shebangs except the first one
# @arg $@ files:String[] the files to filter
# @exitcode * if one of the filter command fails
# @stdin you can use stdin as alternative to files argument
# @stdout the filtered content
# shellcheck disable=SC2120
Filters::removeDuplicatedShebangs() {
  sed -E '1!{/^#!/d;}' "$@"
}
