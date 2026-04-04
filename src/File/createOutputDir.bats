#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/File/createOutputDir.sh
source "${BATS_TEST_DIRNAME}/createOutputDir.sh"

setup() {
  BATS_TMP_DIR="$(mktemp -d -p "${TMPDIR:-/tmp}" -t bats-$$-XXXXXX)"
  export TMPDIR="${BATS_TMP_DIR}"
}

teardown() {
  rm -Rf "${BATS_TMP_DIR}" || true
}

function File::createOutputDir { #@test
  local outputDir
  local tempDir
  tempDir="$(mktemp -d)"

  outputDir=$(File::createOutputDir "" "${tempDir}")
  run [ -d "${outputDir}" ]
  assert_success
  assert_equal "${outputDir}" "${tempDir}"
}

function File::createOutputDir_with_provided_directory { #@test
  local outputDir
  local tempDir
  tempDir="$(mktemp -d)"
  local providedDir="${tempDir}/test-output"

  outputDir=$(File::createOutputDir "${providedDir}" "${tempDir}")
  run [ -d "${outputDir}" ]
  assert_success
  assert_equal "${outputDir}" "${providedDir}"
}

function File::createOutputDir_existing_directory { #@test
  local outputDir
  local tempDir
  tempDir="$(mktemp -d)"

  outputDir=$(File::createOutputDir "${tempDir}" "/some/default")
  run [ -d "${outputDir}" ]
  assert_success
  assert_equal "${outputDir}" "${tempDir}"
}

function File::createOutputDir_fails_on_permission_denied { #@test
  run File::createOutputDir "/root/no-permission-test" "/tmp"
  assert_failure
}

function File::createOutputDir_creates_nested_directories { #@test
  local outputDir
  local tempDir
  tempDir="$(mktemp -d)"
  local nestedDir="${tempDir}/level1/level2/level3"

  outputDir=$(File::createOutputDir "${nestedDir}" "${tempDir}")
  run [ -d "${outputDir}" ]
  assert_success
  assert_equal "${outputDir}" "${nestedDir}"
}
