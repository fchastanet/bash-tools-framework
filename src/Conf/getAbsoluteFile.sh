#!/usr/bin/env bash

# @description get absolute conf file from specified conf folder deduced using these rules
#   * from absolute file (ignores <confFolder> and <extension>)
#   * relative to where script is executed (ignores <confFolder> and <extension>)
#   * from home/.bash-tools/<confFolder>
#   * from framework conf/<confFolder>
#
# @arg $1 confFolder:String the directory name (not the path) to list
# @arg $2 conf:String file to use without extension
# @arg $3 extension:String the extension (.sh by default)
#
# @stdout absolute conf filename
# @exitcode 1 if file is not found in any location
Conf::getAbsoluteFile() {
  local confFolder="$1"
  local conf="$2"
  local extension="${3-.sh}"
  if [[ -n "${extension}" && "${extension:0:1}" != "." ]]; then
    extension=".${extension}"
  fi

  testAbs() {
    local result
    result="$(realpath -e "$1" 2>/dev/null)"
    # shellcheck disable=SC2181
    if [[ "$?" = "0" && -f "${result}" ]]; then
      echo "${result}"
      return 0
    fi
    return 1
  }

  # conf is absolute file (including extension)
  testAbs "${confFolder}${extension}" && return 0
  # conf is absolute file
  testAbs "${confFolder}" && return 0
  # conf is absolute file (including extension)
  testAbs "${conf}${extension}" && return 0
  # conf is absolute file
  testAbs "${conf}" && return 0

  # relative to where script is executed (including extension)
  if [[ -n "${CURRENT_DIR+xxx}" ]]; then
    testAbs "$(File::concatenatePath "${CURRENT_DIR}" "${confFolder}")/${conf}${extension}" && return 0
  fi
  # from home/.bash-tools/<confFolder>
  testAbs "$(File::concatenatePath "${HOME}/.bash-tools" "${confFolder}")/${conf}${extension}" && return 0

  if [[ -n "${FRAMEWORK_ROOT_DIR+xxx}" ]]; then
    # from framework conf/<confFolder> (including extension)
    testAbs "$(File::concatenatePath "${FRAMEWORK_ROOT_DIR}/conf" "${confFolder}")/${conf}${extension}" && return 0

    # from framework conf/<confFolder>
    testAbs "$(File::concatenatePath "${FRAMEWORK_ROOT_DIR}/conf" "${confFolder}")/${conf}" && return 0
  fi

  # file not found
  Log::displayError "conf file '${conf}' not found"

  return 1
}
