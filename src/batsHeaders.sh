#!/usr/bin/env bash

export SCRIPT_NAME="test"
FRAMEWORK_ROOT_DIR=$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")/.." && pwd -P)
vendorDir="${FRAMEWORK_ROOT_DIR}/vendor"
srcDir="${FRAMEWORK_ROOT_DIR}/src"
export FRAMEWORK_ROOT_DIR="${FRAMEWORK_ROOT_DIR}"
export BASH_FRAMEWORK_DISPLAY_LEVEL=3

# shellcheck source=/src/_includes/_mandatoryHeader.sh
source "${srcDir}/_includes/_mandatoryHeader.sh"

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=/src/_standalone/Bats/assert_lines_count.sh
source "${srcDir}/_standalone/Bats/assert_lines_count.sh"
# shellcheck source=/src/Env/__all.sh
source "${srcDir}/Env/__all.sh"
# shellcheck source=src/Log/__all.sh
source "${srcDir}/Log/__all.sh"
# shellcheck source=src/UI/theme.sh
source "${srcDir}/UI/theme.sh"
# shellcheck source=src/Assert/tty.sh
source "${srcDir}/Assert/tty.sh"

initLogs() {
  local envFile="$1"
  unset BASH_FRAMEWORK_THEME
  unset BASH_FRAMEWORK_LOG_LEVEL
  unset BASH_FRAMEWORK_DISPLAY_LEVEL
  BASH_FRAMEWORK_ENV_FILES=("${BATS_TEST_DIRNAME}/testsData/${envFile}")
  Env::requireLoad
  Log::requireLoad
}
