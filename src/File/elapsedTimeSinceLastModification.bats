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

teardown() {
  rm -f "/tmp/fileExists" || true
}

function File::elapsedTimeSinceLastModificationNoFileProvided { #@test
  run File::elapsedTimeSinceLastModification
  assert_failure 1
  assert_output ""
}

function File::elapsedTimeSinceLastModificationFileNotExists { #@test
  run File::elapsedTimeSinceLastModification "/tmp/fileNotExists"
  assert_failure 1
  assert_output ""
}

function File::elapsedTimeSinceLastModification { #@test
  touch -d "1 hour ago" /tmp/fileExists
  run File::elapsedTimeSinceLastModification "/tmp/fileExists"
  assert_success
  # shellcheck disable=SC2154
  ((output >= 3600 && output <= 3602))
}
