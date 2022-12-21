#!/usr/bin/env bash

ROOT_DIR=$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")" && pwd -P)
SRC_DIR="$(cd "${BIN_DIR}/src" && pwd -P)"
BIN_DIR="$(cd "${ROOT_DIR}/bin" && pwd -P)"

# shellcheck source=./src/_includes/_header.sh
source "${SRC_DIR}/_includes/_header.sh"
# shellcheck source=./src/Log/_.sh
source "${SRC_DIR}/Log/_.sh"
# shellcheck source=./src/Log/displayInfo.sh
source "${SRC_DIR}/Log/displayInfo.sh"
# shellcheck source=./src/Log/displayError.sh
source "${SRC_DIR}/Log/displayError.sh"

# exitCode will be > 0 if at least one file has been updated or created
((exitCode = 0)) || true
compileFile() {
  local srcFile="$1"
  local srcRelativeFile BIN_FILE ROOT_DIR_RELATIVE_TO_BIN_DIR
  srcRelativeFile="$(realpath -m --relative-to="${ROOT_DIR}" "${srcFile}")"
  BIN_FILE="$(grep -E '# BIN_FILE=' "${srcFile}" | sed -E 's/^#[^=]+=[ \t]*(.*)[ \t]*$/\1/' || :)"
  BIN_FILE="$(echo "${BIN_FILE}" | envsubst)"
  ROOT_DIR_RELATIVE_TO_BIN_DIR="$(grep -E '# ROOT_DIR_RELATIVE_TO_BIN_DIR=' "${srcFile}" | sed -E 's/^#[^=]+=[ \t]*(.*)[ \t]*$/\1/' || :)"
  if [[ -z "${BIN_FILE}" ]]; then
    BIN_FILE="$(echo "${srcFile}" | sed -E "s#^${ROOT_DIR}/src/#${ROOT_DIR}/bin/#" | sed -E 's#.sh$##')"
  else
    if ! realpath "${BIN_FILE}" &>/dev/null; then
      Log::displayError "${srcFile} does not define a valid BIN_FILE value"
      return 1
    fi
  fi

  Log::displayInfo "Writing file ${BIN_FILE} from ${srcFile}"
  mkdir -p "$(dirname "${BIN_FILE}")"
  local oldMd5
  oldMd5="$(md5sum "${BIN_FILE}" 2>/dev/null | awk '{print $1}' || echo "new")"
  "${ROOT_DIR}/build/compile" "${srcFile}" "${srcRelativeFile}" "${ROOT_DIR_RELATIVE_TO_BIN_DIR}" |
    sed -E '/^# (BIN_FILE|ROOT_DIR_RELATIVE_TO_BIN_DIR)=.*$/d' >"${BIN_FILE}"
  chmod +x "${BIN_FILE}"
  if [[ "${oldMd5}" != "$(md5sum "${BIN_FILE}" | awk '{print $1}' || "new")" ]]; then
    ((++exitCode))
  fi
}

while IFS= read -r file; do
  compileFile "${file}"
done < <(find "${ROOT_DIR}/src" -name "*.sh")

if [[ "${exitCode}" != "0" ]]; then
  Log::displayError "${exitCode} file(s) have been updated by this build"
  exit "${exitCode}"
fi
