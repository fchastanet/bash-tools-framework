#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Git/shallowClone.sh
source "${srcDir}/Git/shallowClone.sh"

teardown() {
  unstub_all
  rm -Rf "${BATS_TEST_TMPDIR}/fakeRepo" || true
}

function Git::shallowClone::firstTime { #@test
  stub git \
    "init : true" \
    "remote add origin https://github.com/fchastanet/fakeRepo.git : true" \
    "-c advice.detachedHead=false fetch  --progress --depth 1 origin master : true" \
    "reset --hard FETCH_HEAD : true"

  run Git::shallowClone \
    "https://github.com/fchastanet/fakeRepo.git" \
    "${BATS_TEST_TMPDIR}/fakeRepo" \
    "master" 2>&1

  assert_success
  assert_output --partial "INFO    - Installing ${BATS_TEST_TMPDIR}/fakeRepo ..."
}

function Git::shallowClone::secondTimeUpdate { #@test
  mkdir -p "${BATS_TEST_TMPDIR}/fakeRepo/.git"
  stub git \
    "-c advice.detachedHead=false fetch --progress --depth 1 origin master : true" \
    "reset --hard FETCH_HEAD : true"

  run Git::shallowClone \
    "https://github.com/fchastanet/fakeRepo.git" \
    "${BATS_TEST_TMPDIR}/fakeRepo" \
    "master" 2>&1

  assert_success
  assert_output --partial "INFO    - Repository ${BATS_TEST_TMPDIR}/fakeRepo already installed"
}

function Git::shallowClone::onNonGitFolderNotForced { #@test
  mkdir -p "${BATS_TEST_TMPDIR}/fakeRepo"
  run Git::shallowClone \
    "https://github.com/fchastanet/fakeRepo.git" \
    "${BATS_TEST_TMPDIR}/fakeRepo" \
    "master" \
    "0" 2>&1

  assert_failure 1
  assert_output --partial "ERROR   - Destination ${BATS_TEST_TMPDIR}/fakeRepo already exists, use force option to automatically delete the destination"
  # check directory has not been deleted
  [[ -d "${BATS_TEST_TMPDIR}/fakeRepo" ]]
}

function Git::shallowClone::onNonGitFolderForced { #@test
  mkdir -p "${BATS_TEST_TMPDIR}/fakeRepo"
  stub git \
    "init : true" \
    "remote add origin https://github.com/fchastanet/fakeRepo.git : true" \
    "-c advice.detachedHead=false fetch --progress --depth 1 origin master : true" \
    "reset --hard FETCH_HEAD : true"

  run Git::shallowClone \
    "https://github.com/fchastanet/fakeRepo.git" \
    "${BATS_TEST_TMPDIR}/fakeRepo" \
    "master" \
    "FORCE_DELETION" 2>&1

  assert_success
  # shellcheck disable=SC2154
  assert_lines_count 2
  assert_line --index 0 --partial "WARN    - Removing ${BATS_TEST_TMPDIR}/fakeRepo ..."
  assert_line --index 1 --partial "INFO    - Installing ${BATS_TEST_TMPDIR}/fakeRepo ..."
}
