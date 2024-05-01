#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Install/structure.sh
source "${srcDir}/Install/structure.sh"

function Install::simpleStructure { #@test
  mkdir -p "${BATS_TEST_TMPDIR}/srcDir/dir1/dir1.1"
  touch "${BATS_TEST_TMPDIR}/srcDir/dir1/dir1-file1"
  Install::file() {
    echo "cp ${1#${BATS_TEST_TMPDIR}/} ${2#${BATS_TEST_TMPDIR}/}"
  }
  local resultStatus=0
  USERNAME="$(id -un)" USERGROUP="$(id -gn)" \
  PRETTY_ROOT_DIR="${BATS_TEST_TMPDIR}" Install::structure \
    "${BATS_TEST_TMPDIR}/srcDir" "${BATS_TEST_TMPDIR}/destDir" \
    &>"${BATS_TEST_TMPDIR}/result" || resultStatus=$?
  [[ "${resultStatus}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 2
  assert_line --index 0 "cp srcDir/dir1/dir1-file1 destDir/dir1/dir1-file1"
  assert_line --index 1 --partial "SUCCESS - Installed directory 'destDir' from 'srcDir'"
  run diff -q "${BATS_TEST_TMPDIR}/srcDir" "${BATS_TEST_TMPDIR}/destDir"

  assert_success
}

function complexStructureDataset {
  local dirName="$1"
  mkdir -p "${BATS_TEST_TMPDIR}/${dirName}/dir1/dir1.1"
  mkdir -p "${BATS_TEST_TMPDIR}/${dirName}/dir1/dir1.2" # empty dir
  mkdir -p "${BATS_TEST_TMPDIR}/${dirName}/dir1/dir1.2/dir1.2.1"
  mkdir -p "${BATS_TEST_TMPDIR}/${dirName}/dir2/dir2.1/dir2.1.1" # 2 files, one hidden
}

function complexStructureDatasetWithFiles {
  local dirName="$1"
  complexStructureDataset "${dirName}"
  touch "${BATS_TEST_TMPDIR}/${dirName}/dir1/dir1-file1"
  touch "${BATS_TEST_TMPDIR}/${dirName}/dir1/dir1.2/dir1.2.1/dir1.2.1-file1"
  touch "${BATS_TEST_TMPDIR}/${dirName}/dir2/dir2.1/dir2.1.1/.dir2.1.1-file1"
  touch "${BATS_TEST_TMPDIR}/${dirName}/dir2/dir2.1/dir2.1.1/dir2.2.1-file2"
}

function Install::complexStructureWithHiddenFiles { #@test
  complexStructureDatasetWithFiles "srcDir"
  Install::file() {
    echo "cp ${1#${BATS_TEST_TMPDIR}/} ${2#${BATS_TEST_TMPDIR}/}"
  }

  local resultStatus=0
  USERNAME="$(id -un)" USERGROUP="$(id -gn)" \
  PRETTY_ROOT_DIR="${BATS_TEST_TMPDIR}" Install::structure \
    "${BATS_TEST_TMPDIR}/srcDir" "${BATS_TEST_TMPDIR}/destDir" \
    &>"${BATS_TEST_TMPDIR}/result" || resultStatus=$?
  [[ "${resultStatus}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_success
  assert_lines_count 5
  assert_line --index 0 "cp srcDir/dir2/dir2.1/dir2.1.1/.dir2.1.1-file1 destDir/dir2/dir2.1/dir2.1.1/.dir2.1.1-file1"
  assert_line --index 1 "cp srcDir/dir2/dir2.1/dir2.1.1/dir2.2.1-file2 destDir/dir2/dir2.1/dir2.1.1/dir2.2.1-file2"
  assert_line --index 2 "cp srcDir/dir1/dir1-file1 destDir/dir1/dir1-file1"
  assert_line --index 3 "cp srcDir/dir1/dir1.2/dir1.2.1/dir1.2.1-file1 destDir/dir1/dir1.2/dir1.2.1/dir1.2.1-file1"
  assert_line --index 4 --partial "SUCCESS - Installed directory 'destDir' from 'srcDir'"

  run diff -q "${BATS_TEST_TMPDIR}/srcDir" "${BATS_TEST_TMPDIR}/destDir"

  assert_success
}

function Install::complexStructureTargetStructureAlreadySet { #@test
  complexStructureDatasetWithFiles "srcDir"
  complexStructureDataset "destDir"
  Install::file() {
    echo "cp ${1#${BATS_TEST_TMPDIR}/} ${2#${BATS_TEST_TMPDIR}/}"
  }

  local resultStatus=0
  USERNAME="$(id -un)" USERGROUP="$(id -gn)" \
  PRETTY_ROOT_DIR="${BATS_TEST_TMPDIR}" Install::structure \
    "${BATS_TEST_TMPDIR}/srcDir" "${BATS_TEST_TMPDIR}/destDir" \
    &>"${BATS_TEST_TMPDIR}/result" || resultStatus=$?
  [[ "${resultStatus}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_success
  assert_lines_count 5
  assert_line --index 0 "cp srcDir/dir2/dir2.1/dir2.1.1/.dir2.1.1-file1 destDir/dir2/dir2.1/dir2.1.1/.dir2.1.1-file1"
  assert_line --index 1 "cp srcDir/dir2/dir2.1/dir2.1.1/dir2.2.1-file2 destDir/dir2/dir2.1/dir2.1.1/dir2.2.1-file2"
  assert_line --index 2 "cp srcDir/dir1/dir1-file1 destDir/dir1/dir1-file1"
  assert_line --index 3 "cp srcDir/dir1/dir1.2/dir1.2.1/dir1.2.1-file1 destDir/dir1/dir1.2/dir1.2.1/dir1.2.1-file1"
  assert_line --index 4 --partial "SUCCESS - Installed directory 'destDir' from 'srcDir'"

  run diff -q "${BATS_TEST_TMPDIR}/srcDir" "${BATS_TEST_TMPDIR}/destDir"
  assert_success
}

function Install::complexStructureSrcTargetIdentical { #@test
  complexStructureDatasetWithFiles "srcDir"
  complexStructureDatasetWithFiles "destDir"
  Install::file() {
    echo "cp ${1#${BATS_TEST_TMPDIR}/} ${2#${BATS_TEST_TMPDIR}/}"
  }

  local resultStatus=0
  USERNAME="$(id -un)" USERGROUP="$(id -gn)" \
  PRETTY_ROOT_DIR="${BATS_TEST_TMPDIR}" Install::structure \
    "${BATS_TEST_TMPDIR}/srcDir" "${BATS_TEST_TMPDIR}/destDir" \
    &>"${BATS_TEST_TMPDIR}/result" || resultStatus=$?
  [[ "${resultStatus}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_success
  assert_lines_count 5
  assert_line --index 0 "cp srcDir/dir2/dir2.1/dir2.1.1/.dir2.1.1-file1 destDir/dir2/dir2.1/dir2.1.1/.dir2.1.1-file1"
  assert_line --index 1 "cp srcDir/dir2/dir2.1/dir2.1.1/dir2.2.1-file2 destDir/dir2/dir2.1/dir2.1.1/dir2.2.1-file2"
  assert_line --index 2 "cp srcDir/dir1/dir1-file1 destDir/dir1/dir1-file1"
  assert_line --index 3 "cp srcDir/dir1/dir1.2/dir1.2.1/dir1.2.1-file1 destDir/dir1/dir1.2/dir1.2.1/dir1.2.1-file1"
  assert_line --index 4 --partial "SUCCESS - Installed directory 'destDir' from 'srcDir'"

  run diff -q "${BATS_TEST_TMPDIR}/srcDir" "${BATS_TEST_TMPDIR}/destDir"
  assert_success
}
