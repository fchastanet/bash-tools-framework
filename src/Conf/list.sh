#!/usr/bin/env bash

# Public: list files of dir with given extension and display it as a list one by line
#
# @param {String} dir $1 the directory to list
# @param {String} prefix $2 the profile file prefix (default: "")
# @param {String} ext $3 the extension
# @param {String} findOptions $4 find options, eg: -type d
# @paramDefault {String} findOptions $4 '-type f'
# @param {String} indentStr $5 the indentation can be any string compatible with sed not containing any /
# @paramDefault {String} indentStr $5 '       - '
# @output list of files without extension/directory
# eg:
#       - default.local
#       - default.remote
#       - localhost-root
# @return 1 if directory does not exists
Conf::list() {
  local dir="$1"
  local prefix="${2:-}"
  local ext="${3}"
  local findOptions="${4--type f}"
  local indentStr="${5-       - }"

  if [[ ! -d "${dir}" ]]; then
    Log::displayError "Directory ${dir} does not exist"
  fi
  if [[ -n "${ext}" && "${ext:0:1}" != "." ]]; then
    ext=".${ext}"
  fi
  (
    # shellcheck disable=SC2086
    cd "${dir}" &&
      find . -maxdepth 1 ${findOptions} -name "${prefix}*${ext}" |
      sed -E "s#^\./${prefix}##g" |
        sed -E "s#${ext}\$##g" | sort | sed -E "s#^#${indentStr}#"
  )
}
