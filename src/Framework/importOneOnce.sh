#!/usr/bin/env bash

# Public: source given file.
# Do not source it again if it has already been sourced.
# try to source relative path from each lib path in this order:
# * vendor/bash-framework
# * vendor
# * calling script path
# * absolute path
#
# **Arguments**:
# * $1 file to source
#
# **Exit**: code 1 if error while sourcing
Framework::importOneOnce() {
  local libPath="$1"
  shift
  if [[ -z "${libPath}" ]]; then
    return
  fi

  # absolute file
  if [[ "${libPath}" == /* ]]; then
    Framework::SourcePath "${libPath}" "$@"
  else
    # try local library
    # try vendor dir
    # try from project root
    # try absolute path
    {
      local localPath="${__BASH_FRAMEWORK_VENDOR_PATH:?}"
      localPath="${localPath}/${libPath}"
      Framework::SourcePath "${localPath}" "$@"
    } ||
      Framework::SourcePath "${__BASH_FRAMEWORK_VENDOR_PATH:?}/${libPath}" "$@" ||
      Framework::SourcePath "${__BASH_FRAMEWORK_CALLING_SCRIPT:?}/${libPath}" "$@" ||
      Framework::SourcePath "${libPath}" "$@" || Log::fatal "Cannot import ${libPath}"
  fi
}
