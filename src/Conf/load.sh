#!/usr/bin/env bash

# @description get absolute file from name deduced using these rules
#   * using absolute/relative <conf> file (ignores <confFolder> and <extension>
#   * from home/.bash-tools/<confFolder>/<conf><extension> file
#   * from framework conf/<conf><extension> file
#
# @arg $1 confFolder:String directory to use (traditionally below bash-tools conf folder)
# @arg $2 conf:String file to use without extension
# @arg $3 extension:String file extension to use (default: .sh)
#
# @exitcode 1 if file not found or error during file loading
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
      confFile="${FRAMEWORK_ROOT_DIR}/conf/${confFolder}/${conf}${extension}"
    fi
  fi
  if [[ ! -f "${confFile}" ]]; then
    return 1
  fi
  # shellcheck disable=SC1090
  source "${confFile}"
}
