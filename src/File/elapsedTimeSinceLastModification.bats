#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/File/elapsedTimeSinceLastModification.sh
source "${srcDir}/File/elapsedTimeSinceLastModification.sh"

setup() {
  export TMPDIR="${BATS_RUN_TMPDIR}"
}

function File::elapsedTimeSinceLastModificationNoFileProvided { #@test
  run File::elapsedTimeSinceLastModification
  assert_failure 1
  assert_output ""
}

function File::elapsedTimeSinceLastModificationFileNotExists { #@test
  run File::elapsedTimeSinceLastModification "${BATS_RUN_TMPDIR}/fileNotExists"
  assert_failure 1
  assert_output ""
}

function File::elapsedTimeSinceLastModification { #@test
  touch -d "1 hour ago" "${BATS_RUN_TMPDIR}/fileExists"
  run File::elapsedTimeSinceLastModification "${BATS_RUN_TMPDIR}/fileExists"
  assert_success
  # shellcheck disable=SC2154
  ((output >= 3600 && output <= 3602))
}
