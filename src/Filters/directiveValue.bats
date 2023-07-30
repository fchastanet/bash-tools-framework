#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Filters/directiveValue.sh
source "${BATS_TEST_DIRNAME}/directiveValue.sh"

function Filters::directiveValue::noMatch { #@test
  echo "TEST" | {
    run Filters::directiveValue "TEST"
    assert_failure 1
    assert_output ""
  }
}

function Filters::directiveValue::notFound { #@test
  echo "# TEST=" | {
    run Filters::directiveValue "NOT_FOUND"
    assert_failure 1
    assert_output ""
  }
}

function Filters::directiveValue::simple { #@test
  echo -e "# TEST=testValue" | {
    run Filters::directiveValue "TEST"
    assert_success
    assert_output "testValue"
  }
}

function Filters::directiveValue::caseSensitive { #@test
  echo -e "# TEST=testValue" | {
    run Filters::directiveValue "test"
    assert_failure 1
    assert_output ""
  }
}

function Filters::directiveValue::matchSimpleWithSpaces { #@test
  echo -e "# TEST = \tvalue test \t " | {
    run Filters::directiveValue "TEST"
    assert_success
    assert_output "value test"
  }
}

function Filters::directiveValue::matchSimpleWithSpacesAndQuotes { #@test
  echo -e $"# TEST = \t\"'value test\"' \t " | {
    run Filters::directiveValue "TEST"
    assert_success
    assert_output "value test"
  }
}

function Filters::directiveValue::multiLines { #@test
  echo -e "
# TEST =value1
# TEST =value2
# TEST =value3
" | {
    run Filters::directiveValue "TEST"
    assert_success
    assert_output "value1"
  }
}
