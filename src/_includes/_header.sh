#!/usr/bin/env bash

# shellcheck disable=SC2034
SCRIPT_NAME=${0##*/}

# ensure that no user aliases could interfere with
# commands used in this script
unalias -a || true

if [[ -n "${BIN_DIR}" ]]; then
  export PATH="${BIN_DIR}":${PATH}
fi
if [[ -n "${VENDOR_BIN_DIR}" ]]; then
  export PATH="${VENDOR_BIN_DIR}":${PATH}
fi

srcDir="$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")/.." && pwd -P)"
# shellcheck source=/src/Assert/fileWritable.sh
source "${srcDir}/Assert/fileWritable.sh"
# shellcheck source=/src/Assert/validPath.sh
source "${srcDir}/Assert/validPath.sh"
# shellcheck source=/src/Args/parseVerbose.sh
source "${srcDir}/Args/parseVerbose.sh"
# shellcheck source=src/Log/__all.sh
source "${srcDir}/Log/__all.sh"
# shellcheck source=src/Env/load.sh
source "${srcDir}/Env/load.sh"
# shellcheck source=src/_includes/_commonHeader.sh
source "${srcDir}/_includes/_commonHeader.sh"

Env::load
export BASH_FRAMEWORK_DISPLAY_LEVEL="${BASH_FRAMEWORK_DISPLAY_LEVEL:-__LEVEL_WARNING}"
Args::parseVerbose "${__LEVEL_INFO}" "$@" || true
# shellcheck source=/src/Args/parseVerbose.sh
longArg="--verbose" shortArg="-v" source "${srcDir}/Args/remove.sh"

Log::load
