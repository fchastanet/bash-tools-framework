#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/File/getAbsolutePath.sh
source "${srcDir}/File/getAbsolutePath.sh"

function File::getAbsolutePath::empty { #@test
  run File::getAbsolutePath ""
  assert_failure
  assert_output "realpath: '': No such file or directory"
}

function File::getAbsolutePath::root { #@test
  run File::getAbsolutePath "/"
  assert_success
  assert_output "/"
}

function File::getAbsolutePath::relativeToCurrentDir { #@test
  run File::getAbsolutePath ".."
  assert_success
  assert_output "$(dirname "$(pwd)")"
}

function File::getAbsolutePath::relativeToTestDirname { #@test
  run File::getAbsolutePath "${BATS_TEST_DIRNAME}/../Env"
  assert_success
  assert_output "$(dirname "${BATS_TEST_DIRNAME}")/Env"
}
