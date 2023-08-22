#!/usr/bin/env bash

# shellcheck disable=SC2034
SCRIPT_NAME=${0##*/}

# ensure that no user aliases could interfere with
# commands used in this script
unalias -a || true

if [[ -n "${COMMAND_BIN_DIR}" ]]; then
  export PATH="${COMMAND_BIN_DIR}":${PATH}
fi
if [[ -n "${FRAMEWORK_VENDOR_BIN_DIR}" ]]; then
  export PATH="${FRAMEWORK_VENDOR_BIN_DIR}":${PATH}
fi

srcDir="$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")/.." && pwd -P)"
# shellcheck source=src/_includes/_mandatoryHeader.sh
source "${srcDir}/_includes/_mandatoryHeader.sh"
# shellcheck source=/src/Assert/fileWritable.sh
source "${srcDir}/Assert/fileWritable.sh"
# shellcheck source=/src/Assert/validPath.sh
source "${srcDir}/Assert/validPath.sh"
# shellcheck source=/src/Array/remove.sh
source "${srcDir}/Array/remove.sh"
# shellcheck source=src/Env/__all.sh
source "${srcDir}/Env/__all.sh"
# shellcheck source=src/Log/__all.sh
source "${srcDir}/Log/__all.sh"
# shellcheck source=src/Env/requireLoad.sh
source "${srcDir}/Env/requireLoad.sh"
# shellcheck source=src/_includes/_commonHeader.sh
source "${srcDir}/_includes/_commonHeader.sh"
