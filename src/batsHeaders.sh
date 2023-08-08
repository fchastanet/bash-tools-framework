#!/usr/bin/env bash

# ensure that no user aliases could interfere with
# commands used in this script
unalias -a || true

export SCRIPT_NAME="test"
FRAMEWORK_ROOT_DIR=$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")/.." && pwd -P)
vendorDir="${FRAMEWORK_ROOT_DIR}/vendor"
srcDir="${FRAMEWORK_ROOT_DIR}/src"
export FRAMEWORK_ROOT_DIR="${FRAMEWORK_ROOT_DIR}"
# shellcheck disable=SC2034
export LC_ALL=POSIX

set -o errexit
set -o pipefail

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=/src/_standalone/Bats/assert_lines_count.sh
source "${srcDir}/_standalone/Bats/assert_lines_count.sh"
# shellcheck source=/src/Env/load.sh
source "${srcDir}/Env/load.sh"
# shellcheck source=src/Log/__all.sh
source "${srcDir}/Log/__all.sh"
