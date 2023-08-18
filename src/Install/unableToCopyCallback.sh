#!/usr/bin/env bash

# @description install callback
#   default callback used called when file copy has failed
# @arg $1 fromFile:String
# @arg $2 targetFile:String
# @env FRAMEWORK_ROOT_DIR used to make paths relative to this directory to reduce length of messages
# @exitcode 1 always fail
# @stderr diagnostics information is displayed
# @see Install::file
Install::unableToCopyCallback() {
  local fromDir="$1"
  local fileName="$2"
  local targetFile="$3"
  Log::fatal "unable to copy file '${fromDir#"${FRAMEWORK_ROOT_DIR}/"}/${fileName}' to '${targetFile}'"
}
