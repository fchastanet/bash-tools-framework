#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Embed/assertAsName.sh
source "${srcDir}/Embed/assertAsName.sh"

function Embed::assertAsName::Empty { #@test
  run Embed::assertAsName ""
  assert_failure 1
  assert_output --partial "ERROR   - Invalid embed name ''. AS property name can only be composed by letters, numbers, underscore."
}

function Embed::assertAsName::@ { #@test
  run Embed::assertAsName "@"
  assert_failure 1
  assert_output --partial "ERROR   - Invalid embed name '@'. AS property name can only be composed by letters, numbers, underscore."
}

function Embed::assertAsName::Accents { #@test
  run Embed::assertAsName "François"
  assert_failure 1
  assert_output --partial "ERROR   - Invalid embed name 'François'. AS property name can only be composed by letters, numbers, underscore."
}

function Embed::assertAsName::Valid { #@test
  run Embed::assertAsName "embedded_data"
  assert_success
  assert_output ""
}
