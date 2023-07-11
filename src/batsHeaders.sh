#!/usr/bin/env bash

export SCRIPT_NAME="test"
ROOT_DIR=$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")/.." && pwd -P)
vendorDir="${ROOT_DIR}/vendor"
srcDir="${ROOT_DIR}/src"
export FRAMEWORK_DIR="${ROOT_DIR}"
# shellcheck disable=SC2034
TMPDIR="$(mktemp -d -p "${TMPDIR:-/tmp}" -t bash-framework-bats-$$-XXXXXX)"
export TMPDIR

set -o errexit
set -o pipefail

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=/src/_standalones/Bats/assert_lines_count.sh
source "${srcDir}/_standalones/Bats/assert_lines_count.sh"
# shellcheck source=/src/Env/load.sh
source "${srcDir}/Env/load.sh"
# shellcheck source=src/Log/_.sh
source "${srcDir}/Log/_.sh"
# shellcheck source=src/Log/displayDebug.sh
source "${srcDir}/Log/displayDebug.sh"
# shellcheck source=src/Log/displayError.sh
source "${srcDir}/Log/displayError.sh"
# shellcheck source=src/Log/displayHelp.sh
source "${srcDir}/Log/displayHelp.sh"
# shellcheck source=src/Log/displayInfo.sh
source "${srcDir}/Log/displayInfo.sh"
# shellcheck source=src/Log/displaySkipped.sh
source "${srcDir}/Log/displaySkipped.sh"
# shellcheck source=src/Log/displaySuccess.sh
source "${srcDir}/Log/displaySuccess.sh"
# shellcheck source=src/Log/displayWarning.sh
source "${srcDir}/Log/displayWarning.sh"
# shellcheck source=src/Log/logMessage.sh
source "${srcDir}/Log/logMessage.sh"
# shellcheck source=src/Log/fatal.sh
source "${srcDir}/Log/fatal.sh"
# shellcheck source=src/Log/logFatal.sh
source "${srcDir}/Log/logFatal.sh"
# shellcheck source=src/Log/logDebug.sh
source "${srcDir}/Log/logDebug.sh"
# shellcheck source=src/Log/logError.sh
source "${srcDir}/Log/logError.sh"
# shellcheck source=src/Log/logHelp.sh
source "${srcDir}/Log/logHelp.sh"
# shellcheck source=src/Log/logInfo.sh
source "${srcDir}/Log/logInfo.sh"
# shellcheck source=src/Log/logSkipped.sh
source "${srcDir}/Log/logSkipped.sh"
# shellcheck source=src/Log/logSuccess.sh
source "${srcDir}/Log/logSuccess.sh"
# shellcheck source=src/Log/logWarning.sh
source "${srcDir}/Log/logWarning.sh"
# shellcheck source=src/Log/rotate.sh
source "${srcDir}/Log/rotate.sh"
