#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/File/upFind.sh
source "${srcDir}/File/upFind.sh"
# shellcheck source=/src/Array/contains.sh
source "${srcDir}/Array/contains.sh"

function File::upFindFromPathIsAFileFound { #@test
  run File::upFind "${srcDir}/File/upFind.sh" "batsHeaders.sh"
  assert_success
  assert_output "${srcDir}/batsHeaders.sh"
}

function File::upFindFound { #@test
  run File::upFind "${srcDir}/File" "batsHeaders.sh"
  assert_success
  assert_output "${srcDir}/batsHeaders.sh"
}

function File::upFindUntilNotFound { #@test
  run File::upFind "${srcDir}/File" ".framework-config" "${srcDir}"
  assert_failure
  assert_output ""
}

function File::upFindCurrentDirectory { #@test
  run File::upFind "${srcDir}/File" "upFind.bats" "${srcDir}"
  assert_success
  assert_output "${srcDir}/File/upFind.bats"
}

function File::upFindUntilFound { #@test
  run File::upFind "${srcDir}/File" ".framework-config" "${FRAMEWORK_DIR}"
  assert_success
  assert_output "${FRAMEWORK_DIR}/.framework-config"
}

function File::upFindUntilFoundMultiplePath { #@test
  run File::upFind "${srcDir}/File" ".framework-config" "notExisting" "/etc" "${FRAMEWORK_DIR}"
  assert_success
  assert_output "${FRAMEWORK_DIR}/.framework-config"
}
