#!/usr/bin/env bash

# Public: insert file content inside another file after a
# pattern
#
# @param {String} file $1 file in which fileToImport will be
#   injected
# @param {String} fileToImport $2 file to inject before the
#   token
# @param {String} token $3 token needs to be properly escaped
#   for usage inside sed // regexp
File::insertFileAfterToken() {
  local file="$1"
  local fileToImport="$2"
  local token="$3"

  #sed -E -i "/${token}/ r ${fileToImport}" "${file}"
  sed -i -E -e "
      /${token}/!b
      r ${fileToImport}
      :a;n;ba
    " "${file}"
}
