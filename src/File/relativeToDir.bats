#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/File/relativeToDir.sh
source "${BATS_TEST_DIRNAME}/relativeToDir.sh"

function File::relativeToDir::noArgument { #@test
  run File::relativeToDir
  assert_failure 1
  assert_output "realpath: '': No such file or directory"
}

function File::relativeToDir::noRelativeDirArg { #@test
  run File::relativeToDir "test"
  assert_failure 1
  assert_output "realpath: '': No such file or directory"
}

function File::relativeToDir::relativeToRoot { #@test
  run File::relativeToDir "/test" "/"
  assert_success
  assert_output "test"
}

function File::relativeToDir::descendantDir { #@test
  run File::relativeToDir "/home/user/test" "/home"
  assert_success
  assert_output "user/test"
}

function File::relativeToDir::unrelatedDirs { #@test
  run File::relativeToDir "/home/user/test" "/root"
  assert_success
  assert_output "../home/user/test"
}

function File::relativeToDir::upDir { #@test
  run File::relativeToDir "/home" "/home/user"
  assert_success
  assert_output ".."
}
