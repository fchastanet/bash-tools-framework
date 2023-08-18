#!/usr/bin/env bash

# @description insert file content inside another file before a
# pattern
#
# @arg $1 file:String file in which fileToImport will be
#   injected
# @arg $2 fileToImport:String file to inject before the
#   token
# @arg $3 token:String token needs to be properly escaped
#   for usage inside sed // regexp
File::insertFileBeforeToken() {
  local file="$1"
  local fileToImport="$2"
  local token="$3"

  # old version inserts at each occurrence
  # sed -E -i "0,/${token}/ {
  #     h
  #     r ${fileToImport}
  #     g
  #     N
  #   }" "${file}"

  sed -i -E -e "
      /${token}/!b
      r ${fileToImport}
      N;:a;n;$!ba
    " "${file}"
}
