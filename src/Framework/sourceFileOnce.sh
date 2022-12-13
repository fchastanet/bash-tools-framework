#!/usr/bin/env bash

declare -ag __BASH_FRAMEWORK_IMPORTED_FILES

# Internal: source given file. Do not source it again if it has already been sourced.
#
# **Arguments**:
# * $1 file to source
#
# **Exit**: code 1 if error while sourcing
Framework::sourceFileOnce() {
  local libPath="$1"
  shift
  if [[ -z "${libPath}" ]]; then
    return
  fi

  [[ ! -f "${libPath}" ]] && return 1 # && e="Cannot import ${libPath}" throw

  libPath="$(Framework::GetAbsolutePath "${libPath}")"

  # [[ -e "${libPath}" ]] && echo "Trying to load from: ${libPath}"
  if [[ -f "${libPath}" ]]; then
    ## if already imported let's return
    # if declare -f "Array::contains" &> /dev/null &&
    if [[ "${__bash_framework__allowFileReloading-}" != true && -n "${__BASH_FRAMEWORK_IMPORTED_FILES[*]}" ]] && Array::contains "${libPath}" "${__BASH_FRAMEWORK_IMPORTED_FILES[@]}"; then
      # DEBUG subject=level3 Log "File previously imported: ${libPath}"
      return 0
    fi

    # DEBUG subject=level2 Log "Importing: ${libPath}"

    __BASH_FRAMEWORK_IMPORTED_FILES+=("${libPath}")
    Framework::WrapSource "${libPath}" "$@"

  else
    :
    # DEBUG subject=level2 Log "File doesn't exist when importing: ${libPath}"
  fi
}
