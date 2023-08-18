#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Compiler/Embed/assertAsName.sh
source "${srcDir}/Compiler/Embed/assertAsName.sh"

function Compiler::Embed::assertAsName::Empty { #@test
  run Compiler::Embed::assertAsName ""
  assert_failure 1
  assert_output --partial "ERROR   - Invalid embed name ''. AS property name can only be composed by letters, numbers, underscore."
}

function Compiler::Embed::assertAsName::@ { #@test
  run Compiler::Embed::assertAsName "@"
  assert_failure 1
  assert_output --partial "ERROR   - Invalid embed name '@'. AS property name can only be composed by letters, numbers, underscore."
}

function Compiler::Embed::assertAsName::Accents { #@test
  run Compiler::Embed::assertAsName "François"
  assert_failure 1
  assert_output --partial "ERROR   - Invalid embed name 'François'. AS property name can only be composed by letters, numbers, underscore."
}

function Compiler::Embed::assertAsName::Valid { #@test
  run Compiler::Embed::assertAsName "embedded_data"
  assert_success
  assert_output ""
}
