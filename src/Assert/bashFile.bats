#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Assert/bashFile.sh
source "${srcDir}/Assert/bashFile.sh"

function Assert::bashFile::shFile { #@test
  run Assert::bashFile "${srcDir}/Assert/bashFile.sh"
  assert_success
  assert_output ""
}

function Assert::bashFile::alternateShebang { #@test
  run Assert::bashFile "${BATS_TEST_DIRNAME}/testsData/alternateShebang.sh"
  assert_success
  assert_output ""
}

function Assert::bashFile::markdown { #@test
  run Assert::bashFile "${ROOT_DIR}/README.md"
  assert_failure 1
  assert_output ""
}

function Assert::bashFile::missingFile { #@test
  run Assert::bashFile "${BATS_TEST_DIRNAME}/testsData/missingFile.sh"
  assert_failure 2
  assert_output ""
}
