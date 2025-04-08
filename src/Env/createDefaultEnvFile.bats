#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Env/createDefaultEnvFile.sh
source "${srcDir}/Env/createDefaultEnvFile.sh"
# shellcheck source=src/Framework/createTempFile.sh
source "${srcDir}/Framework/createTempFile.sh"

setup() {
  TMPDIR="$(mktemp -d -p "${TMPDIR:-/tmp}" -t bats-$$-XXXXXX)"
}

function Env::createDefaultEnvFile:unset { #@test
  unset BASH_FRAMEWORK_THEME
  unset BASH_FRAMEWORK_LOG_LEVEL
  unset BASH_FRAMEWORK_DISPLAY_LEVEL
  unset BASH_FRAMEWORK_LOG_FILE
  unset BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION
  run Env::createDefaultEnvFile
  assert_success
  assert_lines_count 1
  assert_output --partial "${TMPDIR}/createDefaultEnvFileEnvFile"
  run cat "${output}"
  assert_lines_count 5
  assert_line --index 0 "BASH_FRAMEWORK_THEME=default"
  assert_line --index 1 "BASH_FRAMEWORK_LOG_LEVEL=0"
  assert_line --index 2 "BASH_FRAMEWORK_DISPLAY_LEVEL=3"
  assert_line --index 3 'BASH_FRAMEWORK_LOG_FILE="${BASH_FRAMEWORK_LOG_FILE:-"${FRAMEWORK_ROOT_DIR}/logs/${SCRIPT_NAME}.log"}"'
  assert_line --index 4 'BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION=5'
}
