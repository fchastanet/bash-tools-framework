#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/File/replaceTokenByInput.sh
source "${srcDir}/File/replaceTokenByInput.sh"
# shellcheck source=/src/Framework/createTempFile.sh
source "${srcDir}/Framework/createTempFile.sh"
# shellcheck source=/src/Filters/removeAnsiCodes.sh
source "${srcDir}/Filters/removeAnsiCodes.sh"

function File::replaceTokenByInput::OneTokenWithoutAnsiCodes { #@test
  cp "${BATS_TEST_DIRNAME}/testsData/replaceTokenByInput.txt" \
    "${BATS_TEST_TMPDIR}/replaceTokenByInput.txt"
  cat "${BATS_TEST_DIRNAME}/testsData/replaceTokenByInput.toInject.txt" | File::replaceTokenByInput \
    "@token@" \
    "${BATS_TEST_TMPDIR}/replaceTokenByInput.txt"

  diff "${BATS_TEST_DIRNAME}/testsData/replaceTokenByInput.expected.txt" \
    "${BATS_TEST_TMPDIR}/replaceTokenByInput.txt"
}

function File::replaceTokenByInput::OneTokenWithAnsiCodes { #@test
  cp "${BATS_TEST_DIRNAME}/testsData/replaceTokenByInput.txt" \
    "${BATS_TEST_TMPDIR}/replaceTokenByInput.txt"
  # cspell:disable
  (
    echo -e "\e[31mreplace\e[32mToken\e[1;30mByInput injected\e[7;49;33m"
  ) >"${BATS_TEST_TMPDIR}/replaceTokenByInput.toInject.txt"
  # cspell:enable
  cat "${BATS_TEST_TMPDIR}/replaceTokenByInput.toInject.txt" | File::replaceTokenByInput \
    "@token@" \
    "${BATS_TEST_TMPDIR}/replaceTokenByInput.txt"

  diff "${BATS_TEST_DIRNAME}/testsData/replaceTokenByInput.expected.txt" \
    "${BATS_TEST_TMPDIR}/replaceTokenByInput.txt"
}

function File::replaceTokenByInput::TwoTokens { #@test
  cp "${BATS_TEST_DIRNAME}/testsData/replaceTokenByInput2Tokens.txt" \
    "${BATS_TEST_TMPDIR}/replaceTokenByInput2Tokens.txt"
  cat "${BATS_TEST_DIRNAME}/testsData/replaceTokenByInput2Tokens.toInject.txt" | File::replaceTokenByInput \
    "@token@" \
    "${BATS_TEST_TMPDIR}/replaceTokenByInput2Tokens.txt"

  diff "${BATS_TEST_DIRNAME}/testsData/replaceTokenByInput2Tokens.expected.txt" \
    "${BATS_TEST_TMPDIR}/replaceTokenByInput2Tokens.txt" >&3
}

function File::replaceTokenByInput::NoMatchingPattern { #@test
  cp "${BATS_TEST_DIRNAME}/testsData/replaceTokenByInput.txt" \
    "${BATS_TEST_TMPDIR}/replaceTokenByInput.txt"
  cat "${BATS_TEST_DIRNAME}/testsData/replaceTokenByInput.toInject.txt" | File::replaceTokenByInput \
    "@tokenNotFound@" \
    "${BATS_TEST_TMPDIR}/replaceTokenByInput.txt"

  diff "${BATS_TEST_DIRNAME}/testsData/replaceTokenByInput.txt" \
    "${BATS_TEST_TMPDIR}/replaceTokenByInput.txt"
}
