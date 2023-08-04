#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/File/insertFileAfterToken.sh
source "${srcDir}/File/insertFileAfterToken.sh"

function File::insertFileAfterToken::OneToken { #@test
  cp "${BATS_TEST_DIRNAME}/testsData/insertFileAfterToken.txt" \
    "${BATS_TEST_TMPDIR}/insertFileAfterToken.txt"
  File::insertFileAfterToken \
    "${BATS_TEST_TMPDIR}/insertFileAfterToken.txt" \
    "${BATS_TEST_DIRNAME}/testsData/insertFileAfterToken.toInject.txt" \
    "# FUNCTIONS"

  diff "${BATS_TEST_DIRNAME}/testsData/insertFileAfterToken.expected.txt" \
    "${BATS_TEST_TMPDIR}/insertFileAfterToken.txt"
}

function File::insertFileAfterToken::TwoTokens { #@test
  cp "${BATS_TEST_DIRNAME}/testsData/insertFileAfterToken2.txt" \
    "${BATS_TEST_TMPDIR}/insertFileAfterToken2.txt"
  File::insertFileAfterToken \
    "${BATS_TEST_TMPDIR}/insertFileAfterToken2.txt" \
    "${BATS_TEST_DIRNAME}/testsData/insertFileAfterToken.toInject.txt" \
    "# FUNCTIONS"

  diff "${BATS_TEST_DIRNAME}/testsData/insertFileAfterToken2.expected.txt" \
    "${BATS_TEST_TMPDIR}/insertFileAfterToken2.txt" >&3
}

function File::insertFileAfterToken::InsertTwice { #@test
  cp "${BATS_TEST_DIRNAME}/testsData/insertFileAfterToken2.txt" \
    "${BATS_TEST_TMPDIR}/insertFileAfterToken3.txt"
  File::insertFileAfterToken \
    "${BATS_TEST_TMPDIR}/insertFileAfterToken3.txt" \
    "${BATS_TEST_DIRNAME}/testsData/insertFileAfterToken.toInject.txt" \
    "# FUNCTIONS"
  File::insertFileAfterToken \
    "${BATS_TEST_TMPDIR}/insertFileAfterToken3.txt" \
    "${BATS_TEST_DIRNAME}/testsData/insertFileAfterToken.toInject3.txt" \
    "# FUNCTIONS"

  diff "${BATS_TEST_DIRNAME}/testsData/insertFileAfterToken3.expected.txt" \
    "${BATS_TEST_TMPDIR}/insertFileAfterToken3.txt"
}

function File::insertFileAfterToken::NoMatchingPattern { #@test
  cp "${BATS_TEST_DIRNAME}/testsData/insertFileAfterToken2.txt" \
    "${BATS_TEST_TMPDIR}/insertFileAfterToken4.txt"
  run File::insertFileAfterToken \
    "${BATS_TEST_TMPDIR}/insertFileAfterToken4.txt" \
    "${BATS_TEST_DIRNAME}/testsData/insertFileAfterToken.toInject.txt" \
    "# NOT MATCHING PATTERN"
  assert_success
  diff "${BATS_TEST_DIRNAME}/testsData/insertFileAfterToken2.txt" \
    "${BATS_TEST_TMPDIR}/insertFileAfterToken4.txt"
}
