#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/File/detectBashFile.sh
source "${srcDir}/File/detectBashFile.sh"
# shellcheck source=/src/Assert/bashFile.sh
source "${srcDir}/Assert/bashFile.sh"

function File::detectBashFile::shFile { #@test
  run File::detectBashFile "${srcDir}/File/detectBashFile.sh"
  assert_success
  assert_output "${srcDir}/File/detectBashFile.sh"
}

function File::detectBashFile::alternateShebang { #@test
  run File::detectBashFile "${BATS_TEST_DIRNAME}/testsData/alternateShebang.sh"
  assert_success
  assert_output "${BATS_TEST_DIRNAME}/testsData/alternateShebang.sh"
}

function File::detectBashFile::markdown { #@test
  run File::detectBashFile "${rootDir}/README.md"
  assert_success
  assert_output ""
}

function File::detectBashFile::missingFile { #@test
  export TMPDIR="${BATS_RUN_TMPDIR}"
  run File::detectBashFile "${BATS_TEST_DIRNAME}/testsData/missingFile.sh"
  assert_success
  assert_output ""
}
