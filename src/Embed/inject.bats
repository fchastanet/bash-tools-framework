#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Embed/inject.sh
source "${srcDir}/Embed/inject.sh"
# shellcheck source=src/Embed/filter.sh
source "${srcDir}/Embed/filter.sh"
# shellcheck source=src/Embed/parse.sh
source "${srcDir}/Embed/parse.sh"
# shellcheck source=src/Embed/assertAsName.sh
source "${srcDir}/Embed/assertAsName.sh"
# shellcheck source=src/Embed/assertResource.sh
source "${srcDir}/Embed/assertResource.sh"
# shellcheck source=src/Embed/embed.sh
source "${srcDir}/Embed/embed.sh"
# shellcheck source=src/Array/contains.sh
source "${srcDir}/Array/contains.sh"
# shellcheck source=src/Assert/validVariableName.sh
source "${srcDir}/Assert/validVariableName.sh"
# shellcheck source=src/Assert/bashFrameworkFunction.sh
source "${srcDir}/Assert/bashFrameworkFunction.sh"
# shellcheck source=src/Embed/embedFile.sh
source "${srcDir}/Embed/embedFile.sh"
# shellcheck source=src/Embed/embedDir.sh
source "${srcDir}/Embed/embedDir.sh"
# shellcheck source=src/Embed/embedFrameworkFunction.sh
source "${srcDir}/Embed/embedFrameworkFunction.sh"
# shellcheck source=src/Filters/removeExternalQuotes.sh
source "${srcDir}/Filters/removeExternalQuotes.sh"

function Embed::inject::noMatch { #@test
  local status
  local -a embeddedNames=()
  local -a embeddedResources=()
  Embed::inject embeddedNames embeddedResources <"${BATS_TEST_DIRNAME}/testsData/binaryFile" \
    >"${BATS_TEST_TMPDIR}/inject" 2>&1
  status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/inject"
  assert_output ""
}

function Embed::inject::matchButInvalidAsName { #@test
  local status="0"
  local -a embeddedNames=()
  local -a embeddedResources=()
  Embed::inject embeddedNames embeddedResources <<<"# EMBED 'test' as 'François'" \
    >"${BATS_TEST_TMPDIR}/inject" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/inject"
  assert_lines_count 1
  assert_output --partial "ERROR   - Invalid embed name 'François'. AS property name can only be composed by letters, numbers, underscore."
}

function Embed::inject::matchButInvalidResource { #@test
  local status="0"
  local -a embeddedNames=()
  local -a embeddedResources=()
  Embed::inject embeddedNames embeddedResources <<<"# EMBED 'test' as 'valid'" \
    >"${BATS_TEST_TMPDIR}/inject" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/inject"
  assert_lines_count 1
  assert_output --partial "ERROR   - Invalid embed resource 'test'. The resource is neither a file, directory nor bash framework function"
}

function Embed::inject::matchButAsNameAlreadyIncluded { #@test
  local status="0"
  local -a embeddedNames=('valid')
  local -a embeddedResources=()
  Embed::inject embeddedNames embeddedResources <<<"# EMBED '${BATS_TEST_DIRNAME}/testsData/binaryFile' as 'valid'" \
    >"${BATS_TEST_TMPDIR}/inject" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/inject"
  assert_lines_count 1
  assert_output --partial "SKIPPED - Embed asName valid has already been imported previously"
}

function Embed::inject::worksWithWarningResourceAlreadyIncluded { #@test
  local status="0"
  local -a embeddedNames=()
  local -a embeddedResources=("${BATS_TEST_DIRNAME}/testsData/binaryFile")
  local _COMPILE_ROOT_DIR="${ROOT_DIR}"
  local PERSISTENT_TMPDIR="${BATS_TEST_TMPDIR}"
  Embed::inject embeddedNames embeddedResources <<<"# EMBED '${BATS_TEST_DIRNAME}/testsData/binaryFile' as 'valid'" \
    >"${BATS_TEST_TMPDIR}/inject" 2>"${BATS_TEST_TMPDIR}/injectError" || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/injectError"
  assert_lines_count 1
  assert_output --partial "WARN    - Embed resource ${BATS_TEST_DIRNAME}/testsData/binaryFile has already been imported previously with a different name, ensure to deduplicate"
  run diff "${BATS_TEST_TMPDIR}/inject" "${BATS_TEST_DIRNAME}/testsData/injectBinaryFile.expected.txt"
  assert_success
}

function Embed::inject::twiceSameResourceDifferentAsName { #@test
  local status="0"
  local -a embeddedNames=()
  local -a embeddedResources=()
  local _COMPILE_ROOT_DIR="${ROOT_DIR}"
  local PERSISTENT_TMPDIR="${BATS_TEST_TMPDIR}"
  dir="${BATS_TEST_DIRNAME}" envsubst <"${BATS_TEST_DIRNAME}/testsData/twiceSameResourceDifferentAsName.txt" |
    Embed::inject embeddedNames embeddedResources \
      >"${BATS_TEST_TMPDIR}/inject" 2>"${BATS_TEST_TMPDIR}/injectError" || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/injectError"
  assert_output --partial "WARN    - Embed resource ${BATS_TEST_DIRNAME}/testsData/binaryFile has already been imported previously with a different name, ensure to deduplicate"
  run diff "${BATS_TEST_TMPDIR}/inject" "${BATS_TEST_DIRNAME}/testsData/twiceSameResourceDifferentAsName.expected.txt"
  assert_success
}
