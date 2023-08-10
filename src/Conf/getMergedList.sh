#!/usr/bin/env bash

# Public: list the conf files list available in bash-tools/conf/<conf> folder
# and those overridden in ${HOME}/.bash-tools/<conf> folder
# **Arguments**:
# * $1 confFolder the directory name (not the path) to list
# * $2 the extension (sh by default)
# * $3 the indentation ('       - ' by default) can be any string compatible with sed not containing any /
#
# **Output**: list of files without extension/directory
# eg:
#       - default.local
#       - default.remote
#       - localhost-root
Conf::getMergedList() {
  local confFolder="$1"
  local extension="${2:-sh}"
  local indentStr="${3:-       - }"

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
