#!/usr/bin/env bash

# Public: get absolute conf file from specified conf folder deduced using these rules
#   * from absolute file (ignores <confFolder> and <extension>)
#   * relative to where script is executed (ignores <confFolder> and <extension>)
#   * from home/.bash-tools/<confFolder>
#   * from framework conf/<confFolder>
#
# **Arguments**:
# * $1 confFolder the directory name (not the path) to list
# * $2 conf file to use without extension
# * $3 the extension (sh by default)
#
# Returns absolute conf filename
Profiles::getAbsoluteConfFile() {
  local confFolder="$1"
  local conf="$2"
  local extension="${3-.sh}"

  getAbs() {
    local absoluteConfFile=""
    # load conf from absolute file, then home folder, then bash framework conf folder
    absoluteConfFile="${conf}"
    if [[ "${absoluteConfFile:0:1}" = "/" && -f "${absoluteConfFile}" ]]; then
      # file contains /, consider it as absolute filename
      echo "${absoluteConfFile}"
      return 0
    fi

    # relative to where script is executed
    absoluteConfFile="$(realpath "${__BASH_FRAMEWORK_CALLING_SCRIPT}/${conf}" 2>/dev/null || echo "")"
    if [[ -f "${absoluteConfFile}" ]]; then
      echo "${absoluteConfFile}"
      return 0
    fi

    # take extension into account
    if [[ -n "${extension}" && "${extension:0:1}" != "." ]]; then
      extension=".${extension}"
    fi

    # shellcheck source=/conf/dsn/default.local.env
    absoluteConfFile="${HOME}/.bash-tools/${confFolder}/${conf}${extension}"
    if [[ -f "${absoluteConfFile}" ]]; then
      echo "${absoluteConfFile}"
      return 0
    fi
    absoluteConfFile="${ROOT_DIR:?}/conf/${confFolder}/${conf}${extension}"
    if [[ -f "${absoluteConfFile}" ]]; then
      echo "${absoluteConfFile}"
      return 0
    fi

    return 1
  }
  local abs=""
  abs="$(getAbs)" || {
    # file not found
    Log::displayError "conf file '${conf}' not found"
    return 1
  }
  Log::displayDebug "conf file '${conf}' matching '${abs}' file"
  echo "${abs}"
  return 0
}
