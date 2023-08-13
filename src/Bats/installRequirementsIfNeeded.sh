#!/usr/bin/env bash

BASH_FRAMEWORK_BATS_DEPENDENCIES_CHECK_TIMEOUT=86400 # 1 day

# @description install requirements to execute bats
# @warning the following repositories are shallow cloned
# @warning cloning is skipped if vendor/.batsInstalled file exists
# @warning a new check is done everyday
# @warning repository is not updated of a change is detected
# @env BASH_FRAMEWORK_BATS_DEPENDENCIES_CHECK_TIMEOUT int default value 86400 (86400 seconds = 1 day)
# @set BASH_FRAMEWORK_BATS_DEPENDENCIES_INSTALLED String the file created when all git shallow clones have succeeded
# @see https://github.com/bats-core/bats-core.
# @see https://github.com/bats-core/bats-support
# @see https://github.com/bats-core/bats-assert
# @see https://github.com/Flamefire/bats-mock
# @stderr diagnostics information is displayed
# @feature Git::shallowClone
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
