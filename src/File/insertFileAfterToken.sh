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

  # /${token}/! if line does not match pattern
  #    b command is applied : Branch unconditionally to label.
  #       The label may be omitted, in which case the next cycle
  #       is started.
  #    else
  #       r ${fileToImport} : loads the file in pattern space
  #       n;i \\${NL}: n prints the pattern space and add a new line
  #       :a;n;ba : this allows to iterate until the end of the file
  #          :a label a
  #          n: print pattern space (current line)
  #          ba: goto label a
  # n command: replace the pattern space with the next line of input.
  #   If there is no more input then sed exits without processing any
  #   more commands.

  # trick to insert a new line with sed, as sed does not support \n
  local NL=$'\n'
  sed -i -E -e $"
      /${token}/!b
      r ${fileToImport}
      n;i \\${NL}
      :a;n;ba
    " "${file}"
}
