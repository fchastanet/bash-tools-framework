#!/usr/bin/env bash

BASH_FRAMEWORK_BATS_DEPENDENCIES_INSTALLED="${ROOT_DIR}/vendor/.batsInstalled"
BASH_FRAMEWORK_BATS_DEPENDENCIES_CHECK_TIMEOUT=86400 # 1 day

Bats::installRequirementsIfNeeded() {
  if [[ "$(
    Cache::getFileContentIfNotExpired \
      "${BASH_FRAMEWORK_BATS_DEPENDENCIES_INSTALLED}" \
      "${BASH_FRAMEWORK_BATS_DEPENDENCIES_CHECK_TIMEOUT}"
  )" != "1" ]] \
    ; then
    Log::displayInfo "Install or update bats requirements"
    Git::shallowClone \
      "https://github.com/bats-core/bats-core.git" \
      "${ROOT_DIR}/vendor/bats" \
      "master" \
      "FORCE_DELETION"

    # last revision 2019
    Git::shallowClone \
      "https://github.com/bats-core/bats-support.git" \
      "${ROOT_DIR}/vendor/bats-support" \
      "master" \
      "FORCE_DELETION"

    Git::shallowClone \
      "https://github.com/bats-core/bats-assert.git" \
      "${ROOT_DIR}/vendor/bats-assert" \
      "master" \
      "FORCE_DELETION"

    Git::shallowClone \
      "https://github.com/Flamefire/bats-mock.git" \
      "${ROOT_DIR}/vendor/bats-mock-Flamefire" \
      "master" \
      "FORCE_DELETION"

    echo "1" >"${BASH_FRAMEWORK_BATS_DEPENDENCIES_INSTALLED}"
  fi
}
