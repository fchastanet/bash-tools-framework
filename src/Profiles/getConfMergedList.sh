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
Profiles::getConfMergedList() {
  local confFolder="$1"
  local extension="${2:-sh}"
  local indentStr="${3:-       - }"

  DEFAULT_CONF_DIR="${__BASH_FRAMEWORK_VENDOR_PATH:?}/conf/${confFolder}"
  HOME_CONF_DIR="${HOME}/.bash-tools/${confFolder}"

  (
    if [[ -d "${DEFAULT_CONF_DIR}" ]]; then
      Functions::getList "${DEFAULT_CONF_DIR}" "${extension}" "${indentStr}"
    fi
    if [[ -d "${HOME_CONF_DIR}" ]]; then
      Functions::getList "${HOME_CONF_DIR}" "${extension}" "${indentStr}"
    fi
  ) | sort | uniq
}
