#!/usr/bin/env bash

# @description list the conf files list available in bash-tools/conf/<conf> folder
# and those overridden in ${HOME}/.bash-tools/<conf> folder
#
# @arg $1 confFolder:String the directory name (not the path) to list
# @arg $2 extension:String the extension (.sh by default)
# @arg $3 indentStr:String the indentation ('       - ' by default) can be any string compatible with sed not containing any /
#
# @stdout list of files without extension/directory
# @example text
#       - default.local
#       - default.remote
#       - localhost-root
Conf::getMergedList() {
  local confFolder="$1"
  local extension="${2-sh}"
  local indentStr="${3-       - }"

  local DEFAULT_CONF_DIR="${FRAMEWORK_ROOT_DIR}/conf/${confFolder}"
  local HOME_CONF_DIR="${HOME}/.bash-tools/${confFolder}"

  (
    if [[ -d "${DEFAULT_CONF_DIR}" ]]; then
      Conf::list "${DEFAULT_CONF_DIR}" "" "${extension}" "-type f" "${indentStr}"
    fi
    if [[ -d "${HOME_CONF_DIR}" ]]; then
      Conf::list "${HOME_CONF_DIR}" "" "${extension}" "-type f" "${indentStr}"
    fi
  ) | sort | uniq
}
