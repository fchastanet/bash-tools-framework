#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Filters/metadataValue.sh
source "${BATS_TEST_DIRNAME}/metadataValue.sh"

function Filters::metadataValue::noMatch { #@test
  echo "TEST" | {
    run Filters::metadataValue "TEST"
    assert_failure 1
    assert_output ""
  }
}

function Filters::metadataValue::notFound { #@test
  echo "# TEST=" | {
    run Filters::metadataValue "NOT_FOUND"
    assert_failure 1
    assert_output ""
  }
}

function Filters::metadataValue::simple { #@test
  echo -e "# TEST=testValue" | {
    run Filters::metadataValue "TEST"
    assert_success
    assert_output "testValue"
  }
}

function Filters::metadataValue::caseSensitive { #@test
  echo -e "# TEST=testValue" | {
    run Filters::metadataValue "test"
    assert_failure 1
    assert_output ""
  }
}

function Filters::metadataValue::matchSimpleWithSpaces { #@test
  echo -e "# TEST = \tvalue test \t " | {
    run Filters::metadataValue "TEST"
    assert_success
    assert_output "value test"
  }
}

function Filters::metadataValue::matchSimpleWithSpacesAndQuotes { #@test
  echo -e $"# TEST = \t\"'value test\"' \t " | {
    run Filters::metadataValue "TEST"
    assert_success
    assert_output "value test"
  }
}

function Filters::metadataValue::multiLines { #@test
  echo -e "
# TEST =value1
# TEST =value2
# TEST =value3
" | {
    run Filters::metadataValue "TEST"
    assert_success
    assert_output "value1"
  }
}
