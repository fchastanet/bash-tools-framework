#!/usr/bin/env bash

# Internal: source given file or exits with message on error
#
# **Arguments**:
# * $1 file to source
#
# **Exit**: code 1 if error while sourcing
Framework::wrapSource() {
  local libPath="$1"
  shift
  if [[ -z "${libPath}" ]]; then
    return
  fi

  builtin source "${libPath}" "$@" || Log::fatal "Unable to load ${libPath}"
}
