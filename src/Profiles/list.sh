#!/usr/bin/env bash

# Public: list files of dir with given extension and display it as a list one by line
#
# **Arguments**:
# * $1 the directory to list
# * $2 the profile file prefix (default: "")
# * $3 the extension
# * $4 find options (default: '-type f', eg: -type d)
# * $5 the indentation ('       - ' by default) can be any string compatible with sed not containing any /
# **Output**: list of files without extension/directory
# eg:
#       - default.local
#       - default.remote
#       - localhost-root
Profiles::list() {
  local DIR="$1"
  local PREFIX="${2:-}"
  local EXT="${3}"
  local FIND_OPTIONS="${4--type f}"
  local INDENT_STR="${5-       - }"

  local extension="${EXT}"
  if [[ -n "${EXT}" && "${EXT:0:1}" != "." ]]; then
    extension=".${EXT}"
  fi

  (
    # shellcheck disable=SC2086
    cd "${DIR}" &&
      find . -maxdepth 1 ${FIND_OPTIONS} -name "${PREFIX}*${extension}" |
      sed "s#^\./${PREFIX}##g" |
        sed "s/${EXT}$//g" | sort | sed "s/^/${INDENT_STR}/"
  )
}
