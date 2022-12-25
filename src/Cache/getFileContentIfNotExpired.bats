#!/usr/bin/env bash
vendorDir="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)/vendor"
srcDir="$(cd "${BATS_TEST_DIRNAME}/.." && pwd -P)"

set -o errexit
set -o pipefail

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=src/Cache/getFileContentIfNotExpired.sh
source "${srcDir}/Cache/getFileContentIfNotExpired.sh"

# shellcheck source=src/File/elapsedTimeSinceLastModification.sh
source "${srcDir}/File/elapsedTimeSinceLastModification.sh"

teardown() {
  rm -f "/tmp/fileExists" || true
}

function Cache::getFileContentIfNotExpiredNoFileProvided { #@test
  run Cache::getFileContentIfNotExpired
  assert_failure 1
  assert_output ""
}

function Cache::getFileContentIfNotExpiredFileNotExists { #@test
  run Cache::getFileContentIfNotExpired "/tmp/fileNotExists"
  assert_failure 1
  assert_output ""
}

function Cache::getFileContentIfNotExpiredNotExpired { #@test
  echo "content" >/tmp/fileExists
  touch -d "1 hour ago" /tmp/fileExists
  run Cache::getFileContentIfNotExpired "/tmp/fileExists" "7200"
  assert_success
  assert_output "content"
}

function Cache::getFileContentIfNotExpiredExpired { #@test
  echo "content" >/tmp/fileExists
  touch -d "1 hour ago" /tmp/fileExists
  run Cache::getFileContentIfNotExpired "/tmp/fileExists" "600"
  assert_failure 2
  assert_output ""
}
