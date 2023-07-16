#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/File/insertFileBeforeToken.sh
source "${srcDir}/File/insertFileBeforeToken.sh"

function File::insertFileBeforeToken::OneToken { #@test
  cp "${BATS_TEST_DIRNAME}/testsData/insertFileBeforeToken.txt" \
    "${BATS_RUN_TMPDIR}/insertFileBeforeToken.txt"
  File::insertFileBeforeToken \
    "${BATS_RUN_TMPDIR}/insertFileBeforeToken.txt" \
    "${BATS_TEST_DIRNAME}/testsData/insertFileBeforeToken.toInject.txt" \
    "# FUNCTIONS"

  diff "${BATS_TEST_DIRNAME}/testsData/insertFileBeforeToken.expected.txt" \
    "${BATS_RUN_TMPDIR}/insertFileBeforeToken.txt"
}

function File::insertFileBeforeToken::TwoTokens { #@test
  cp "${BATS_TEST_DIRNAME}/testsData/insertFileBeforeToken2.txt" \
    "${BATS_RUN_TMPDIR}/insertFileBeforeToken2.txt"
  File::insertFileBeforeToken \
    "${BATS_RUN_TMPDIR}/insertFileBeforeToken2.txt" \
    "${BATS_TEST_DIRNAME}/testsData/insertFileBeforeToken.toInject.txt" \
    "# FUNCTIONS"

  diff "${BATS_TEST_DIRNAME}/testsData/insertFileBeforeToken2.expected.txt" \
    "${BATS_RUN_TMPDIR}/insertFileBeforeToken2.txt"
}

function File::insertFileBeforeToken::InsertTwice { #@test
  cp "${BATS_TEST_DIRNAME}/testsData/insertFileBeforeToken2.txt" \
    "${BATS_RUN_TMPDIR}/insertFileBeforeToken3.txt"
  File::insertFileBeforeToken \
    "${BATS_RUN_TMPDIR}/insertFileBeforeToken3.txt" \
    "${BATS_TEST_DIRNAME}/testsData/insertFileBeforeToken.toInject.txt" \
    "# FUNCTIONS"
  File::insertFileBeforeToken \
    "${BATS_RUN_TMPDIR}/insertFileBeforeToken3.txt" \
    "${BATS_TEST_DIRNAME}/testsData/insertFileBeforeToken.toInject3.txt" \
    "# FUNCTIONS"

  diff "${BATS_TEST_DIRNAME}/testsData/insertFileBeforeToken3.expected.txt" \
    "${BATS_RUN_TMPDIR}/insertFileBeforeToken3.txt"
}

function File::insertFileBeforeToken::NoMatchingPattern { #@test
  cp "${BATS_TEST_DIRNAME}/testsData/insertFileBeforeToken2.txt" \
    "${BATS_RUN_TMPDIR}/insertFileBeforeToken4.txt"
  run File::insertFileBeforeToken \
    "${BATS_RUN_TMPDIR}/insertFileBeforeToken4.txt" \
    "${BATS_TEST_DIRNAME}/testsData/insertFileBeforeToken.toInject.txt" \
    "# NOT MATCHING PATTERN"
  assert_success
  diff "${BATS_TEST_DIRNAME}/testsData/insertFileBeforeToken2.txt" \
    "${BATS_RUN_TMPDIR}/insertFileBeforeToken4.txt"
}
