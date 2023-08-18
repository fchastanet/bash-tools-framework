#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/File/garbageCollect.sh
source "${srcDir}/File/garbageCollect.sh"

function teardown() {
  rm -f "${BATS_TEST_TMPDIR}/fileExists" || true
  rm -Rf "${BATS_TEST_TMPDIR}/dir" || true
}
function File::garbageCollect::NoFileProvided { #@test
  run File::garbageCollect
  assert_failure 1
  assert_output ""
}

function File::garbageCollect::FileEmpty { #@test
  run File::garbageCollect ""
  assert_failure 1
  assert_output ""
}

function File::garbageCollect::FileOrDirNotExists { #@test
  run File::garbageCollect "${BATS_TEST_TMPDIR}/fileNotExists"
  assert_success
  assert_output ""
}

function File::garbageCollect::FilesInSubFolderExpiredMaxDepth1 { #@test
  mkdir -p "${BATS_TEST_TMPDIR}/dir/untouchableDir"
  echo "content" >"${BATS_TEST_TMPDIR}/dir/untouchableDir/oldFile"
  touch -d "25 hours ago" "${BATS_TEST_TMPDIR}/dir/untouchableDir"
  touch -d "25 hours ago" "${BATS_TEST_TMPDIR}/dir/untouchableDir/oldFile"
  run File::garbageCollect "${BATS_TEST_TMPDIR}/dir" "1" "1"
  assert_success
  assert_output --partial "INFO    - Garbage collect files older than 1 days in path ${BATS_TEST_TMPDIR}/dir with max depth 1"
  [[ -d "${BATS_TEST_TMPDIR}/dir" ]]
  [[ -d "${BATS_TEST_TMPDIR}/dir/untouchableDir" ]]
  [[ -f "${BATS_TEST_TMPDIR}/dir/untouchableDir/oldFile" ]]
}

function File::garbageCollect::FilesInSubFolderExpiredMaxDepth2 { #@test
  mkdir -p "${BATS_TEST_TMPDIR}/dir/touchableDir"
  touch -d "25 hours ago" "${BATS_TEST_TMPDIR}/dir/touchableDir"
  touch -d "25 hours ago" "${BATS_TEST_TMPDIR}/dir/touchableDir/oldFile"
  touch "${BATS_TEST_TMPDIR}/dir/touchableDir/newFile"
  run File::garbageCollect "${BATS_TEST_TMPDIR}/dir" "1" "2"
  assert_success
  assert_output --partial "INFO    - Garbage collect files older than 1 days in path ${BATS_TEST_TMPDIR}/dir with max depth 2"
  [[ -d "${BATS_TEST_TMPDIR}/dir/touchableDir" ]]
  [[ ! -f "${BATS_TEST_TMPDIR}/dir/touchableDir/oldFile" ]]
  [[ -f "${BATS_TEST_TMPDIR}/dir/touchableDir/newFile" ]]
}

function File::garbageCollect::NotExpired { #@test
  touch -d "1 hour ago" "${BATS_TEST_TMPDIR}/newFile"
  run File::garbageCollect "${BATS_TEST_TMPDIR}/newFile" "1"
  assert_success
  assert_output --partial "INFO    - Garbage collect files older than 1 days in path ${BATS_TEST_TMPDIR}/newFile with max depth 1"
  [[ -f "${BATS_TEST_TMPDIR}/newFile" ]]
}

function File::garbageCollect::ExpiredCalledWithFile { #@test
  mkdir -p "${BATS_TEST_TMPDIR}/touchableDir"
  touch -d "25 hours ago" "${BATS_TEST_TMPDIR}/touchableDir/oldFile"
  run File::garbageCollect "${BATS_TEST_TMPDIR}/touchableDir/oldFile" "1"
  assert_success
  assert_output --partial "INFO    - Garbage collect files older than 1 days in path ${BATS_TEST_TMPDIR}/touchableDir/oldFile with max depth 1"
  [[ -d "${BATS_TEST_TMPDIR}/touchableDir" ]]
  [[ ! -f "${BATS_TEST_TMPDIR}/touchableDir/oldFile" ]]
}

function File::garbageCollect::ExpiredCalledWithDir { #@test
  mkdir -p "${BATS_TEST_TMPDIR}/touchableDir"
  touch -d "25 hours ago" "${BATS_TEST_TMPDIR}/touchableDir/oldFile"
  run File::garbageCollect "${BATS_TEST_TMPDIR}/touchableDir" "1"
  assert_success
  assert_output --partial "INFO    - Garbage collect files older than 1 days in path ${BATS_TEST_TMPDIR}/touchableDir with max depth 1"
  [[ -d "${BATS_TEST_TMPDIR}/touchableDir" ]]
  [[ ! -f "${BATS_TEST_TMPDIR}/touchableDir/oldFile" ]]
}

function File::garbageCollect::NotExpiredLongTime { #@test
  mkdir -p "${BATS_TEST_TMPDIR}/touchableDir"
  touch -d "25 days ago" "${BATS_TEST_TMPDIR}/touchableDir/oldFile"
  run File::garbageCollect "${BATS_TEST_TMPDIR}/touchableDir" "26"
  assert_success
  assert_output --partial "INFO    - Garbage collect files older than 26 days in path ${BATS_TEST_TMPDIR}/touchableDir with max depth 1"
  [[ -d "${BATS_TEST_TMPDIR}/touchableDir" ]]
  [[ -f "${BATS_TEST_TMPDIR}/touchableDir/oldFile" ]]
}

function File::garbageCollect::ExpiredLongTime { #@test
  mkdir -p "${BATS_TEST_TMPDIR}/touchableDir"
  touch -d "25 days ago" "${BATS_TEST_TMPDIR}/touchableDir/oldFile"
  run File::garbageCollect "${BATS_TEST_TMPDIR}/touchableDir" "25"
  assert_success
  assert_output --partial "INFO    - Garbage collect files older than 25 days in path ${BATS_TEST_TMPDIR}/touchableDir with max depth 1"
  [[ -d "${BATS_TEST_TMPDIR}/touchableDir" ]]
  [[ ! -f "${BATS_TEST_TMPDIR}/touchableDir/oldFile" ]]
}
