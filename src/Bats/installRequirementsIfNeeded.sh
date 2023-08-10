#!/usr/bin/env bash

BASH_FRAMEWORK_BATS_DEPENDENCIES_CHECK_TIMEOUT=86400 # 1 day

Bats::installRequirementsIfNeeded() {
  local rootDir="${1:-"${FRAMEWORK_ROOT_DIR}"}"
  BASH_FRAMEWORK_BATS_DEPENDENCIES_INSTALLED="${rootDir}/vendor/.batsInstalled"
  if [[ "$(
    Cache::getFileContentIfNotExpired \
      "${BASH_FRAMEWORK_BATS_DEPENDENCIES_INSTALLED}" \
      "${BASH_FRAMEWORK_BATS_DEPENDENCIES_CHECK_TIMEOUT}"
  )" != "1" ]] \
    ; then
    Log::displayInfo "Install or update bats requirements"
    Git::shallowClone \
      "https://github.com/bats-core/bats-core.git" \
      "${rootDir}/vendor/bats" \
      "master" \
      "FORCE_DELETION"

    # last revision 2019
    Git::shallowClone \
      "https://github.com/bats-core/bats-support.git" \
      "${rootDir}/vendor/bats-support" \
      "master" \
      "FORCE_DELETION"

    Git::shallowClone \
      "https://github.com/bats-core/bats-assert.git" \
      "${rootDir}/vendor/bats-assert" \
      "master" \
      "FORCE_DELETION"

    Git::shallowClone \
      "https://github.com/Flamefire/bats-mock.git" \
      "${rootDir}/vendor/bats-mock-Flamefire" \
      "master" \
      "FORCE_DELETION"

    echo "1" >"${BASH_FRAMEWORK_BATS_DEPENDENCIES_INSTALLED}"
  fi
}
