#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Cache/getFileContentIfNotExpired.sh
source "${srcDir}/Cache/getFileContentIfNotExpired.sh"
# shellcheck source=src/File/elapsedTimeSinceLastModification.sh
source "${srcDir}/File/elapsedTimeSinceLastModification.sh"

function Cache::getFileContentIfNotExpiredNoFileProvided { #@test
  run Cache::getFileContentIfNotExpired
  assert_failure 1
  assert_output ""
}

function Cache::getFileContentIfNotExpiredFileNotExists { #@test
  run Cache::getFileContentIfNotExpired "${BATS_TEST_TMPDIR}/fileNotExists"
  assert_failure 1
  assert_output ""
}

function Cache::getFileContentIfNotExpiredNotExpired { #@test
  echo "content" >"${BATS_TEST_TMPDIR}/fileExists"
  touch -d "1 hour ago" "${BATS_TEST_TMPDIR}/fileExists"
  run Cache::getFileContentIfNotExpired "${BATS_TEST_TMPDIR}/fileExists" "7200"
  assert_success
  assert_output "content"
}

function Cache::getFileContentIfNotExpiredExpired { #@test
  echo "content" >"${BATS_TEST_TMPDIR}/fileExists"
  touch -d "1 hour ago" "${BATS_TEST_TMPDIR}/fileExists"
  run Cache::getFileContentIfNotExpired "${BATS_TEST_TMPDIR}/fileExists" "600"
  assert_failure 2
  assert_output ""
}
