#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Git/shallowClone.sh
source "${srcDir}/Git/shallowClone.sh"

setup() {
  BATS_TMP_DIR="$(mktemp -d -p "${TMPDIR:-/tmp}" -t bats-$$-XXXXXX)"
  export TMPDIR="${BATS_TMP_DIR}"
}

teardown() {
  unstub_all
  rm -Rf "${BATS_TMP_DIR}" || true
}

function Git::shallowClone::firstTime { #@test
  stub git \
    "init : true" \
    "remote add origin https://github.com/fchastanet/fakeRepo.git : true" \
    "-c advice.detachedHead=false fetch --depth 1 origin master : true" \
    "reset --hard FETCH_HEAD : true"

  run Git::shallowClone \
    "https://github.com/fchastanet/fakeRepo.git" \
    "${BATS_TMP_DIR}/fakeRepo" \
    "master" 2>&1

  assert_success
  assert_output --partial "INFO    - Installing ${BATS_TMP_DIR}/fakeRepo ..."
}

function Git::shallowClone::secondTimeUpdate { #@test
  mkdir -p "${BATS_TMP_DIR}/fakeRepo/.git"
  stub git \
    "-c advice.detachedHead=false fetch --progress --depth 1 origin master : true" \
    "reset --hard FETCH_HEAD : true"

  run Git::shallowClone \
    "https://github.com/fchastanet/fakeRepo.git" \
    "${BATS_TMP_DIR}/fakeRepo" \
    "master" 2>&1

  assert_success
  assert_output --partial "INFO    - Repository ${BATS_TMP_DIR}/fakeRepo already installed"
}

function Git::shallowClone::onNonGitFolderNotForced { #@test
  mkdir -p "${BATS_TMP_DIR}/fakeRepo"
  run Git::shallowClone \
    "https://github.com/fchastanet/fakeRepo.git" \
    "${BATS_TMP_DIR}/fakeRepo" \
    "master" \
    "0" 2>&1

  assert_failure 1
  assert_output --partial "ERROR   - Destination ${BATS_TMP_DIR}/fakeRepo already exists, use force option to automatically delete the destination"
  # check directory has not been deleted
  [[ -d "${BATS_TMP_DIR}/fakeRepo" ]]
}

function Git::shallowClone::onNonGitFolderForced { #@test
  mkdir -p "${BATS_TMP_DIR}/fakeRepo"
  stub git \
    "init : true" \
    "remote add origin https://github.com/fchastanet/fakeRepo.git : true" \
    "-c advice.detachedHead=false fetch --progress --depth 1 origin master : true" \
    "reset --hard FETCH_HEAD : true"

  run Git::shallowClone \
    "https://github.com/fchastanet/fakeRepo.git" \
    "${BATS_TMP_DIR}/fakeRepo" \
    "master" \
    "FORCE_DELETION" 2>&1

  assert_success
  # shellcheck disable=SC2154
  [[ "${#lines[@]}" = "2" ]]
  assert_line --index 0 --partial "WARN    - Removing ${BATS_TMP_DIR}/fakeRepo ..."
  assert_line --index 1 --partial "INFO    - Installing ${BATS_TMP_DIR}/fakeRepo ..."
}
