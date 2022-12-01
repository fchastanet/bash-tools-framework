#!/usr/bin/env bash

CURRENT_DIR=$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")" && pwd)
LIB_DIR="$(cd "${CURRENT_DIR}/lib" && pwd)"

# shellcheck source=/lib/_header.sh
source "${LIB_DIR}/_header.sh"
# shellcheck source=/lib/Log/_.sh
source "${LIB_DIR}/Log/_.sh"
# shellcheck source=/lib/Log/displayInfo.sh
source "${LIB_DIR}/Log/displayInfo.sh"
# shellcheck source=/lib/Log/displayError.sh
source "${LIB_DIR}/Log/displayError.sh"

compileFile() {
  srcFile="$1"
  srcRelativeFile="$(realpath -m --relative-to="${ROOT_DIR}" "${srcFile}")"
  BUILD_BIN_FILE="$(grep -E '# BUILD_BIN_FILE=' "${srcFile}" | sed -r 's/^#[^=]+=(.*)$/\1/' || :)"
  BUILD_BIN_FILE="$(echo "${BUILD_BIN_FILE}" | envsubst)"
  if [[ -z "${BUILD_BIN_FILE}" ]]; then
    BUILD_BIN_FILE="$(echo "${srcFile}" | sed -E "s#^${ROOT_DIR}/src/#${ROOT_DIR}/bin/#")"
  else
    if ! realpath "${BUILD_BIN_FILE}" &>/dev/null; then
      Log::displayError "${srcFile} does not define a valid BUILD_BIN_FILE value"
      return 1
    fi
  fi

  Log::displayInfo "Writing file ${BUILD_BIN_FILE} from ${srcFile}"
  mkdir -p "$(dirname "${BUILD_BIN_FILE}")"
  "${ROOT_DIR}/build/compile" "${srcFile}" "${srcRelativeFile}" |
    sed -r '/^# BUILD_BIN_FILE=.*$/d' >"${BUILD_BIN_FILE}"
  chmod +x "${BUILD_BIN_FILE}"
}

while IFS= read -r file; do
  compileFile "${file}"
done < <(find "${ROOT_DIR}/src" -name "*.sh")
