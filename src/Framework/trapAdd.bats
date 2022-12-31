#!/usr/bin/env bash

ROOT_DIR="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
vendorDir="${ROOT_DIR}/vendor"
srcDir="${ROOT_DIR}/src"

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=/src/Framework/trapAdd.sh
source "${srcDir}/Framework/trapAdd.sh"

setup() {
  BATS_TMP_DIR="$(mktemp -d -p "${TMPDIR:-/tmp}" -t bats-$$-XXXXXX)"
  export TMPDIR="${BATS_TMP_DIR}"
}

teardown() {
  unstub_all
  trap - SIGUSR1 SIGUSR2
  rm -Rf "${BATS_TMP_DIR}" || true
}

function Framework::trapAdd::override { #@test
  # shellcheck disable=SC2064
  trap "echo 'SIGUSR1 original' >> '${BATS_TMP_DIR}/trap'" SIGUSR1
  # shellcheck disable=SC2064
  Framework::trapAdd "echo 'SIGUSR1 overridden' >> '${BATS_TMP_DIR}/trap'" SIGUSR1
  kill -SIGUSR1 $$
  run cat "${BATS_TMP_DIR}/trap"
  assert_line --index 0 "SIGUSR1 original"
  assert_line --index 1 "SIGUSR1 overridden"
}

function Framework::trapAdd::override2Events { #@test
  # shellcheck disable=SC2064
  trap "echo 'SIGUSR1 original' >> '${BATS_TMP_DIR}/trap'" SIGUSR1
  # shellcheck disable=SC2064
  trap "echo 'SIGUSR2 original' >> '${BATS_TMP_DIR}/trap'" SIGUSR2
  # shellcheck disable=SC2064
  Framework::trapAdd "echo 'SIGUSR1&2 overridden' >> '${BATS_TMP_DIR}/trap'" SIGUSR1 SIGUSR2
  kill -SIGUSR1 $$

  run cat "${BATS_TMP_DIR}/trap"
  assert_line --index 0 "SIGUSR1 original"
  assert_line --index 1 "SIGUSR1&2 overridden"

  rm "${BATS_TMP_DIR}/trap"
  kill -SIGUSR2 $$
  run cat "${BATS_TMP_DIR}/trap"
  assert_line --index 0 "SIGUSR2 original"
  assert_line --index 1 "SIGUSR1&2 overridden"
}
