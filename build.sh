#!/usr/bin/env bash

CURRENT_DIR=$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")" && pwd)
LIB_DIR="$(cd "${CURRENT_DIR}/lib" && pwd)"

# shellcheck source=/lib/_header.sh
source "${LIB_DIR}/_header.sh"

alias compile='${ROOT_DIR}/build/compile'
compileFile() {
  srcFile="$1"
  destFile="$(echo "${srcFile}" | sed -E "s#^${ROOT_DIR}/src/#${ROOT_DIR}/bin/#")"
  destDir="$(dirname "${destFile}")"
  mkdir -p "${destDir}"

  compile "${srcFile}" "${destFile}"
  chmod +x "${destFile}"
}
export -f compileFile

find "${ROOT_DIR}/src" -name "*.sh" -exec bash -c 'compileFile "$0"' {} ';'
