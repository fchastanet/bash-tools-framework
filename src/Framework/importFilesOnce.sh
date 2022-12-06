#!/usr/bin/env bash

# Public: source given files using Framework::importOne.
#
# **Arguments**:
# * $@ files to source
#
# **Exit**: code 1 if error while sourcing
Framework::importFilesOnce() {
  local savedOptions
  case $- in
    *x*)
      savedOptions='set -x'
      set +x
      ;;
    *)
      savedOptions=''
      ;;
  esac
  local libPath
  for libPath in "$@"; do
    Framework::importOne "${libPath}"
  done
  { eval "${savedOptions}"; } 2>/dev/null
}
