#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Cache/removeCacheFileIfTooOld.sh
source "${srcDir}/Cache/removeCacheFileIfTooOld.sh"

function teardown() {
  rm -f "${BATS_TEST_TMPDIR}/fileExists" || true
  rm -Rf "${BATS_TEST_TMPDIR}/dir" || true
}
function Cache::removeCacheFileIfTooOld::NoFileProvided { #@test
  run Cache::removeCacheFileIfTooOld
  assert_failure 1
  assert_output ""
}

function Cache::removeCacheFileIfTooOld::FileEmpty { #@test
  run Cache::removeCacheFileIfTooOld ""
  assert_failure 1
  assert_output ""
}

function Cache::removeCacheFileIfTooOld::DotDir { #@test
  run Cache::removeCacheFileIfTooOld "."
  assert_failure 2
  assert_output ""
}

function Cache::removeCacheFileIfTooOld::DotDotDir { #@test
  run Cache::removeCacheFileIfTooOld ".."
  assert_failure 2
  assert_output ""
}

function Cache::removeCacheFileIfTooOld::FileNotExists { #@test
  run Cache::removeCacheFileIfTooOld "${BATS_TEST_TMPDIR}/fileNotExists"
  assert_success
  assert_output ""
}

function Cache::removeCacheFileIfTooOld::WithDirectoryDeletesNothingEvenIfExpired { #@test
  mkdir -p "${BATS_TEST_TMPDIR}/dir"
  echo "content" >"${BATS_TEST_TMPDIR}/dir/fileExists"
  touch -d "25 hours ago" "${BATS_TEST_TMPDIR}/dir"
  touch -d "25 hours ago" "${BATS_TEST_TMPDIR}/dir/fileExists"
  run Cache::removeCacheFileIfTooOld "${BATS_TEST_TMPDIR}/dir" "1"
  assert_failure 2
  assert_output ""
  [[ -d "${BATS_TEST_TMPDIR}/dir" ]]
  [[ -f "${BATS_TEST_TMPDIR}/dir/fileExists" ]]
}

function Cache::removeCacheFileIfTooOld::NotExpired { #@test
  echo "content" >"${BATS_TEST_TMPDIR}/fileExists"
  touch -d "1 hour ago" "${BATS_TEST_TMPDIR}/fileExists"
  run Cache::removeCacheFileIfTooOld "${BATS_TEST_TMPDIR}/fileExists" "1"
  assert_success
  assert_output ""
  [[ -f "${BATS_TEST_TMPDIR}/fileExists" ]]
}

function Cache::removeCacheFileIfTooOld::Expired { #@test
  echo "content" >"${BATS_TEST_TMPDIR}/fileExists"
  touch -d "25 hours ago" "${BATS_TEST_TMPDIR}/fileExists"
  run Cache::removeCacheFileIfTooOld "${BATS_TEST_TMPDIR}/fileExists" "1"
  assert_success
  assert_output ""
  [[ ! -f "${BATS_TEST_TMPDIR}/fileExists" ]]
}
