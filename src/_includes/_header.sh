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
# shellcheck source=/src/Assert/fileWritable.sh
source "${srcDir}/Assert/fileWritable.sh"
# shellcheck source=/src/Assert/validPath.sh
source "${srcDir}/Assert/validPath.sh"
# shellcheck source=/src/Args/parseVerbose.sh
source "${srcDir}/Args/parseVerbose.sh"
# shellcheck source=/src/Array/remove.sh
source "${srcDir}/Array/remove.sh"
# shellcheck source=src/Log/__all.sh
source "${srcDir}/Log/__all.sh"
# shellcheck source=src/Env/load.sh
source "${srcDir}/Env/load.sh"
# shellcheck source=src/_includes/_commonHeader.sh
source "${srcDir}/_includes/_commonHeader.sh"

Env::load
export BASH_FRAMEWORK_DISPLAY_LEVEL="${BASH_FRAMEWORK_DISPLAY_LEVEL:-__LEVEL_WARNING}"
Args::parseVerbose "${__LEVEL_INFO}" "$@" || true
declare -a args=("$@")
Array::remove args -v --verbose
set -- "${args[@]}"

Log::load
