#!/usr/bin/env bash

# @description remove comment lines from input or files provided as arguments
# @arg $@ files:String[] (optional) the files to filter
# @env commentLinePrefix String the comment line prefix (default value: #)
# @exitcode 0 if lines filtered or not
# @exitcode 2 if grep fails for any other reasons than not found
# @stdin the file as stdin to filter (alternative to files argument)
# @stdout the filtered lines
# shellcheck disable=SC2120
Filters::commentLines() {
  grep -vxE "[[:blank:]]*(${commentLinePrefix:-#}.*)?" "$@" || test $? = 1
}
