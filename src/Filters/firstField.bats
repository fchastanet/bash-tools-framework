#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Filters/firstField.sh
source "${BATS_TEST_DIRNAME}/firstField.sh"

function Filters::firstField::noMatch { #@test
  echo "" | {
    run Filters::firstField
    assert_success
    assert_output ""
  }
}

function Filters::firstField::withSpaces { #@test
  echo -e " \tfirstField secondField   thirdField" | {
    run Filters::firstField
    assert_success
    assert_output "firstField"
  }
}


function Filters::firstField::bash { #@test
  cat "${BATS_TEST_DIRNAME}/firstField.sh" | {
    run Filters::firstField
    assert_success
    assert_output "#!/bin/bash"
  }
}

function Filters::firstField::bigFile { #@test
  tail -1210 "${FRAMEWORK_ROOT_DIR}/bin/bash-tpl" | {
    run Filters::firstField
    assert_success
    assert_output 'BASH_TPL_DIR_DELIM'
  }
}
