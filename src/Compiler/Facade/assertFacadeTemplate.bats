#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Compiler/Facade/assertFacadeTemplate.sh
source "${srcDir}/Compiler/Facade/assertFacadeTemplate.sh"

function Compiler::Facade::assertFacadeTemplate::Empty { #@test
  run Compiler::Facade::assertFacadeTemplate ""
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Facade template '' is not readable"
}

function Compiler::Facade::assertFacadeTemplate::FileNotFound { #@test
  run Compiler::Facade::assertFacadeTemplate "FileNotFound"
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Facade template 'FileNotFound' is not readable"
}

function Compiler::Facade::assertFacadeTemplate::success { #@test
  run Compiler::Facade::assertFacadeTemplate "${BATS_TEST_DIRNAME}/testsData/emptyTemplate.tpl"
  assert_success
  assert_output ""
}
