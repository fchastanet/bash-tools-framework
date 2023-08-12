#!/usr/bin/env bash

# @description list files of dir with given extension and display it as a list one by line
#
# @arg $1 dir:String the directory to list
# @arg $2 prefix:String the profile file prefix (default: "")
# @arg $3 ext:String the extension
# @arg $4 findOptions:String find options, eg: -type d
# Default value: '-type f'
# @arg $5 indentStr:String the indentation can be any string compatible with sed not containing any /
# Default value: '       - '
# @stdout list of files without extension/directory
# eg:
#       - default.local
#       - default.remote
#       - localhost-root
# @exitcode 1 if directory does not exists
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
