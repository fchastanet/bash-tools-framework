#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Filters/directive.sh
source "${BATS_TEST_DIRNAME}/directive.sh"

function Filters::directive::keepOnlyDirective { #@test
  run Filters::directive "${FILTER_DIRECTIVE_KEEP_ONLY_HEADERS}" "${BATS_TEST_DIRNAME}/testsData/directive.sh"
  assert_output "$(cat "${BATS_TEST_DIRNAME}/testsData/directive.invert0.expected.txt")"
}

function Filters::directive::removeOnlyDirective { #@test
  run Filters::directive "${FILTER_DIRECTIVE_REMOVE_HEADERS}" "${BATS_TEST_DIRNAME}/testsData/directive.sh"
  assert_output "$(cat "${BATS_TEST_DIRNAME}/testsData/directive.invert1.expected.sh")"
}

function Filters::directive::defaultInvertValue { #@test
  {
    run Filters::directive
    assert_output "$(cat "${BATS_TEST_DIRNAME}/testsData/directive.invert0.expected.txt")"
  } <"${BATS_TEST_DIRNAME}/testsData/directive.sh"
}

function Filters::directive::noDirective { #@test
  run Filters::directive "${FILTER_DIRECTIVE_REMOVE_HEADERS}" "${BATS_TEST_DIRNAME}/testsData/noDirective.sh"
  assert_output "$(cat "${BATS_TEST_DIRNAME}/testsData/noDirective.sh")"
}
