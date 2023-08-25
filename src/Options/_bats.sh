#!/usr/bin/env bash

# @description test function generated by Options::generate*
# Options::command and Options::optionVarName
# @env BATS_FIX_TEST int 1 to fix testsData expected files
# @arg $1 testCase:String testCase allowing to retrieved expected result when calling the function
# @arg $2 functionPrefixName:String the function to test (allow to replace generated functionName)
testCommand() {
  local testCase="$1"
  local functionPrefixName="$2"

  # shellcheck disable=SC2154
  [[ "${status}" = "0" ]] || {
    cat "${BATS_TEST_TMPDIR}/result" >&3
    return 1
  }
  run cat "${BATS_TEST_TMPDIR}/result"
  # output is the function name generated
  assert_output --regexp "^${functionPrefixName}[A-F0-9][a-f0-9]{31}\$"
  # shellcheck disable=SC2154
  local functionName="${output}"

  # check function content
  local tmpFile
  tmpFile="${TMPDIR}/src/$(sed -E -e 's#::#/#' <<<"${functionName}").sh"
  [[ -f "${tmpFile}" ]]
  sed -i -E "s#${functionPrefixName}[A-F0-9][a-f0-9]{31}#${functionPrefixName}#" "${tmpFile}"
  diff "${tmpFile}" "${BATS_TEST_DIRNAME}/testsData/${testCase}" >&3 || {
    cat "${tmpFile}" >&3
    if [[ "${BATS_FIX_TEST}" = "1" ]]; then
      (cp -v "${tmpFile}" "${BATS_TEST_DIRNAME}/testsData/${testCase}") >&3
    fi
    return 1
  }
}

# @description source option file deduced by option function name
# @arg $1 functionName:String
sourceOption() {
  local functionName="$1"
  local tmpFile
  tmpFile="${TMPDIR}/src/$(sed -E -e 's#::#/#' <<<"${functionName}").sh"
  # shellcheck source=src/Options/testsData/generateOption.caseBoolean1.sh
  source "${tmpFile}"
}

# @description allows to test generated command function
# @env BATS_FIX_TEST int 1 to fix testsData expected files
# @arg $1 expectedResult:String
# @see Options::generateCommand
checkCommandResult() {
  local expectedResult="$1"
  local tmpFileResultAnsi
  tmpFileResultAnsi="$(mktemp -p "${BATS_TEST_TMPDIR}" -t resultAnsi-$$-XXXXXX)"
  echo -e "${output}" >"${tmpFileResultAnsi}"

  diff -Z <(Filters::removeAnsiCodes "${tmpFileResultAnsi}") <(Filters::removeAnsiCodes <"${BATS_TEST_DIRNAME}/testsData/${expectedResult}") >&3 || {
    echo -e "${output}" >&3
    if [[ "${BATS_FIX_TEST}" = "1" ]]; then
      echo "writing output to ${BATS_TEST_DIRNAME}/testsData/${expectedResult}" >&3
      echo -e "${output}" >"${BATS_TEST_DIRNAME}/testsData/${expectedResult}"
    fi
    return 1
  }
}
