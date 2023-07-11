#!/usr/bin/env bash

# Public: get absolute file from name deduced using these rules
#   * using absolute/relative <conf> file (ignores <confFolder> and <extension>
#   * from home/.bash-tools/<confFolder>/<conf><extension> file
#   * from framework conf/<conf><extension> file
#
# **Arguments**:
# * $1 confFolder to use below bash-tools conf folder
# * $2 conf file to use without extension
# * $3 file extension to use (default: sh)
#
# Returns 1 if file not found or error during file loading
Conf::load() {
  local confFolder="$1"
  local conf="$2"
  local extension="${3:-sh}"

  if [[ -n "${extension}" && "${extension:0:1}" != "." ]]; then
    extension=".${extension}"
  fi
  # if conf is absolute
  local confFile
  if [[ "${conf}" == /* ]]; then
    # file contains /, consider it as absolute filename
    confFile="${conf}"
  else
    # shellcheck source=/conf/dsn/default.local.env
    confFile="${HOME}/.bash-tools/${confFolder}/${conf}${extension}"
    if [[ ! -f "${confFile}" ]]; then
      confFile="${ROOT_DIR}/conf/${confFolder}/${conf}${extension}"
    fi
  fi
  if [[ ! -f "${confFile}" ]]; then
    return 1
  fi
  # shellcheck disable=SC1090
  source "${confFile}"
}
