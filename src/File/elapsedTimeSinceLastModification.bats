#!/usr/bin/env bash
vendorDir="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)/vendor"
srcDir="$(cd "${BATS_TEST_DIRNAME}/.." && pwd -P)"

set -o errexit
set -o pipefail

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=src/File/elapsedTimeSinceLastModification.sh
source "${srcDir}/File/elapsedTimeSinceLastModification.sh"

setup() {
  BATS_TMP_DIR="$(mktemp -d -p "${TMPDIR:-/tmp}" -t bats-$$-XXXXXX)"
  export TMPDIR="${BATS_TMP_DIR}"
}

teardown() {
  rm -Rf "${BATS_TMP_DIR}" || true
}

function File::elapsedTimeSinceLastModificationNoFileProvided { #@test
  run File::elapsedTimeSinceLastModification
  assert_failure 1
  assert_output ""
}

function File::elapsedTimeSinceLastModificationFileNotExists { #@test
  run File::elapsedTimeSinceLastModification "${BATS_TMP_DIR}/fileNotExists"
  assert_failure 1
  assert_output ""
}

function File::elapsedTimeSinceLastModification { #@test
  touch -d "1 hour ago" "${BATS_TMP_DIR}/fileExists"
  run File::elapsedTimeSinceLastModification "${BATS_TMP_DIR}/fileExists"
  assert_success
  # shellcheck disable=SC2154
  ((output >= 3600 && output <= 3602))
}
