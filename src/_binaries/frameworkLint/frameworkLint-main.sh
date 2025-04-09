#!/usr/bin/env bash

# BASH_FRAMEWORK_CONFIG_FILE default options
CURRENT_WARNINGS_FILE="${PERSISTENT_TMPDIR}/currentFrameworkWarningFile.log"
LAST_WARNINGS_FILE="${PERSISTENT_TMPDIR}/lastFrameworkWarningFile.log"

checkEachFunctionHasSrcFile() {
  local file="$1"
  if [[ "${file}" =~ .bats$ ]]; then
    Log::displaySkipped "checkEachFunctionHasSrcFile - File ${file} - bats file"
    return 0
  fi
  if [[ "${file}" =~ ${NON_FRAMEWORK_FILES_REGEXP} ]]; then
    Log::displaySkipped "checkEachFunctionHasSrcFile - File ${file} - rule NON_FRAMEWORK_FILES_REGEXP matches"
    return 0
  fi
  if grep -q -E "${FRAMEWORK_FILES_FUNCTION_MATCHING_IGNORE_REGEXP}" <<<"${file}"; then
    Log::displaySkipped "checkEachFunctionHasSrcFile - File ${file} - rule FRAMEWORK_FILES_FUNCTION_MATCHING_IGNORE_REGEXP matches"
    return 0
  fi
  readarray -t functionsToImport < <(
    Filters::commentLines "${file}" |
      Filters::bashFrameworkFunctions |
      Filters::uniqUnsorted || true
  )
  for functionToImport in "${functionsToImport[@]}"; do
    if echo "${functionToImport}" | grep -q -E "${FRAMEWORK_FUNCTIONS_IGNORE_REGEXP}"; then
      Log::displaySkipped "checkEachFunctionHasSrcFile - File ${file} - Function ${functionToImport} rule FRAMEWORK_FUNCTIONS_IGNORE_REGEXP matches"
      continue
    fi
    local fileNameToImport
    fileNameToImport="$(echo "${functionToImport}" | sed -E 's#::#/#g').sh"

    local found=0
    local srcDir
    for srcDir in "${FRAMEWORK_SRC_DIRS[@]}"; do
      if [[ -f "${srcDir}/${fileNameToImport}" ]]; then
        found=1
      fi
    done
    if [[ "${found}" = "0" ]]; then
      # shellcheck disable=SC2154
      if [[ "${optionFormat}" = "plain" ]]; then
        Log::displayError "checkEachFunctionHasSrcFile - File ${file} - Function ${functionToImport} - does not have a matching source file ${fileNameToImport} in any source directories specified"
      else
        echo "<error severity='error' source='checkEachFunctionHasSrcFile' message='Function ${functionToImport} does not have a matching source file ${fileNameToImport} in any source directories specified'/>"
      fi
      return 1
    fi
  done
}

deduceBashFunctionFromSrcFile() {
  local file="$1"
  local srcDir="$2"

  local relativeFile
  relativeFile="$(
    echo "${file}" | sed -E -e "#${srcDir}##" |
      grep -q -E "${FRAMEWORK_FUNCTIONS_IGNORE_REGEXP}"
  )"
  echo "${relativeFile//\//::}"
}

checkEachSrcFileHasBatsFile() {
  local file="$1"
  if [[ "${file}" =~ ${BATS_FILE_NOT_NEEDED_REGEXP} ]]; then
    Log::displaySkipped "checkEachSrcFileHasBatsFile - File ${file} - rule BATS_FILE_NOT_NEEDED_REGEXP matches"
    return 0
  fi
  if [[ ! "${file}" =~ .sh$ ]]; then
    Log::displaySkipped "checkEachSrcFileHasBatsFile - File ${file} - no suffix .sh"
    return 0
  fi
  local found=0
  local srcDir
  for srcDir in "${FRAMEWORK_SRC_DIRS[@]}"; do
    if realpath --relative-to="${srcDir}" "${file}" &>/dev/null; then
      found=1
    fi
  done
  if [[ "${found}" = "0" ]]; then
    Log::displaySkipped "checkEachSrcFileHasBatsFile - File ${file} - src directory not declared in ${FRAMEWORK_SRC_DIRS[*]}"
    return 0
  fi

  if deduceBashFunctionFromSrcFile "${relativeFile}" "${srcDir}" |
    grep -q -E "${FRAMEWORK_FUNCTIONS_IGNORE_REGEXP}"; then
    Log::displaySkipped "checkEachSrcFileHasBatsFile - File ${file} - matching function name matches FRAMEWORK_FUNCTIONS_IGNORE_REGEXP defined"
    return 0
  fi
  local batsFile="${file%.*}.bats"
  if [[ ! -f "${batsFile}" ]]; then
    reportWarning "checkEachSrcFileHasBatsFile" "${file}" \
      "missing bats file '${batsFile}'"
  fi
}

# search for at least one function that is matching the filename
checkEachSrcFileHasOneFunctionCorrectlyNamed() {
  local srcFile="$1"
  if [[ "${srcFile}" =~ ${NON_FRAMEWORK_FILES_REGEXP} ]]; then
    Log::displaySkipped "srcFileHasOneFunctionCorrectlyNamed - File ${srcFile} - rule NON_FRAMEWORK_FILES_REGEXP matches"
    return 0
  fi
  if grep -q -E "${FRAMEWORK_FILES_FUNCTION_MATCHING_IGNORE_REGEXP}" <<<"${srcFile}"; then
    Log::displaySkipped "srcFileHasOneFunctionCorrectlyNamed - File ${srcFile} - rule FRAMEWORK_FILES_FUNCTION_MATCHING_IGNORE_REGEXP matches"
    return 0
  fi

  local foundFunctionMatching=0
  local expectedFunctionName currentFunction
  local file="${srcFile#src/}"
  expectedFunctionName="$(sed -E 's#/#::#g' <<<"${file%.sh}")"
  if echo "${expectedFunctionName}" | grep -q -E "${FRAMEWORK_FUNCTIONS_IGNORE_REGEXP}"; then
    Log::displaySkipped "srcFileHasOneFunctionCorrectlyNamed - File ${srcFile} - Function ${expectedFunctionName} - rule FRAMEWORK_FUNCTIONS_IGNORE_REGEXP matches"
    return 0
  fi

  while IFS='' read -r currentFunction; do
    if [[ "${currentFunction}" = "${expectedFunctionName}" ]]; then
      foundFunctionMatching=1
    fi
  done < <(sed -E -n 's#^([^([:blank:]]+)\(\)[[:blank:]]*\{#\1#p' "${srcFile}")

  if [[ "${foundFunctionMatching}" = "0" ]]; then
    reportWarning "srcFileHasOneFunctionCorrectlyNamed" "${srcFile}" \
      "Should contain a function named '${expectedFunctionName}' - prefixing with function keyword is not recommended"
    return 0
  fi
}

checkEachSrcFileHasCorrectShdoc() {
  local srcFile="$1"
  if [[ "${srcFile}" =~ ${NON_FRAMEWORK_FILES_REGEXP} ]]; then
    Log::displaySkipped "checkEachSrcFileHasCorrectShDoc - File ${srcFile} - rule NON_FRAMEWORK_FILES_REGEXP matches"
    return 0
  fi
  if grep -q -E "${FRAMEWORK_FILES_FUNCTION_MATCHING_IGNORE_REGEXP}" <<<"${srcFile}"; then
    Log::displaySkipped "checkEachSrcFileHasCorrectShDoc - File ${srcFile} - rule FRAMEWORK_FILES_FUNCTION_MATCHING_IGNORE_REGEXP matches"
    return 0
  fi

  # @see https://regex101.com/r/H2Yrwp/1
  function filterAnnotationNames() {
    sed -n -E 's/^# @(([^ ]|$)+)[ ]*.*$/\1/p' "$@"
  }

  # @see https://regex101.com/r/5oMFQi/1
  # shellcheck disable=SC2120
  function filterInvalidAnnotationNames() {
    grep -v -E '^(name|file|brief|description|section|example|option|arg|noargs|set|env|exitcode|stdin|stdout|stderr|see|warning|require|feature|trap|deprecated|internal|generated)$' "$@"
  }

  function checkValidAnnotationsAreUsed() {
    local srcFile="$1"
    local invalidAnnotation

    while IFS='' read -r invalidAnnotation; do
      reportError "checkEachSrcFileHasCorrectShdoc" "${srcFile}" \
        "shdoc annotation '@${invalidAnnotation}' is invalid"
    done < <(filterAnnotationNames "${srcFile}" | filterInvalidAnnotationNames)
  }

  # check that @require function exists and matches naming convention
  function checkRequiredFunctionExists() {
    local srcFile="$1"
    local requireAnnotation

    while IFS='' read -r requireAnnotation; do
      if ! Assert::bashFrameworkFunction "${requireAnnotation}"; then
        reportError "checkEachSrcFileHasCorrectShdoc" "${srcFile}" \
          "# @require ${requireAnnotation}' does not target a valid bash framework function"
        continue
      fi
      if [[ ! "${requireAnnotation}" =~ ^([A-Za-z0-9_]+[A-Za-z0-9_-]*::)+require([A-Z][a-zA-Z0-9_-]+)$ ]]; then
        reportError "checkEachSrcFileHasCorrectShdoc" "${srcFile}" \
          "# @require ${requireAnnotation}' does not target a bash framework function with naming convention Namespace::requireSomething"
        continue
      fi
      if ! Compiler::findFunctionInSrcDirs "${requireAnnotation}" "${FRAMEWORK_SRC_DIRS[@]}" >/dev/null; then
        reportError "checkEachSrcFileHasCorrectShdoc" "${srcFile}" \
          "# @require ${requireAnnotation}' does not target an existing bash framework function"
      fi
    done < <(sed -n -E 's/^# @require (.*)$/\1/p' "${srcFile}")
  }

  function checkDescriptionAnnotationIsProvided() {
    local srcFile="$1"
    if ! grep -q -E '^# @description .*' "${srcFile}"; then
      reportError "checkEachSrcFileHasCorrectShdoc" "${srcFile}" \
        "missing mandatory sh doc @description annotation"
    fi
  }

  checkValidAnnotationsAreUsed "${srcFile}"
  checkRequiredFunctionExists "${srcFile}"
  checkDescriptionAnnotationIsProvided "${srcFile}"

}

reportError() {
  local category="$1"
  local file="$2"
  local msg="$3"
  if [[ "${optionFormat}" = "plain" ]]; then
    Log::displayError "${category} - File ${file} - ${msg}" 2> >(tee -a "${CURRENT_WARNINGS_FILE}")
  else
    echo "<error severity='error' source='${category}' message='$(sed -E "s/'/\"/g" <<<"${msg}")'/>"
  fi
  ((++errorCount))
}

reportWarning() {
  local category="$1"
  local file="$2"
  local msg="$3"
  if [[ "${optionFormat}" = "plain" ]]; then
    Log::displayWarning "${category} - File ${file} - ${msg}" 2> >(tee -a "${CURRENT_WARNINGS_FILE}")
  else
    echo "<error severity='warning' source='${category}' message='$(sed -E "s/'/\"/g" <<<"${msg}")'/>"
  fi
  ((++warningCount))
}

run() {
  ((errorCount = 0)) || true
  ((warningCount = 0)) || true
  if [[ "${optionFormat}" = "checkstyle" ]]; then
    echo "<?xml version='1.0' encoding='UTF-8'?>"
    echo "<checkstyle>"
  fi
  export -f File::detectBashFile
  export -f Assert::bashFile
  echo >"${CURRENT_WARNINGS_FILE}"

  # shellcheck disable=SC2016
  while IFS='' read -r file; do
    if [[ "${optionFormat}" = "checkstyle" ]]; then
      echo "<file name='${file}'>"
    fi
    Log::displayInfo "Checking file ${file}"
    checkEachFunctionHasSrcFile "${file}" || ((++errorCount))
    checkEachSrcFileHasOneFunctionCorrectlyNamed "${file}" || ((++errorCount))
    checkEachSrcFileHasBatsFile "${file}" || ((++errorCount))
    checkEachSrcFileHasCorrectShdoc "${file}" || ((++errorCount))

    if [[ "${optionFormat}" = "checkstyle" ]]; then
      echo "</file>"
    fi
  done < <(
    git ls-files --exclude-standard |
      xargs -n 10 bash -c 'File::detectBashFile "$@" || true' _ |
      sort ||
      true
  )

  # shellcheck disable=SC2154
  while IFS='' read -r file; do
    if [[ "${optionFormat}" = "checkstyle" ]]; then
      echo "<file name='${file}'>"
    fi
    reportWarning "fileExistence" "${file}" \
      "File ${file} does not exist, git renamed file ?"
    if [[ "${optionFormat}" = "checkstyle" ]]; then
      echo "</file>"
    fi
  done < <(cat "${missingBashFileList}" 2>/dev/null || true)

  if [[ "${optionFormat}" = "plain" ]]; then
    if ((errorCount > 0)); then
      Log::displayError "${errorCount} errors/${warningCount} warnings found !"
    elif ((warningCount > 0)); then
      Log::displayWarning "0 error/${warningCount} warnings found !" 2> >(tee -a "${CURRENT_WARNINGS_FILE}")
    else
      Log::displaySuccess "No error/warning found !"
    fi
  fi

  ((exitCode = 0)) || true
  # shellcheck disable=SC2154
  if ((warningCount > optionExpectedWarningsCount)); then
    local errorMsg="Warnings count(${warningCount}) is greater than expected warnings count(${optionExpectedWarningsCount})"
    if [[ "${optionFormat}" = "plain" ]]; then
      if [[ -f "${LAST_WARNINGS_FILE}" ]]; then
        UI::drawLine "-"
        Log::displayWarning "Differences with last report are the following:"
        diff --old-line-format="" --new-line-format="%L" --unchanged-line-format="" \
          "${LAST_WARNINGS_FILE}" "${CURRENT_WARNINGS_FILE}"
      else
        cp "${CURRENT_WARNINGS_FILE}" "${LAST_WARNINGS_FILE}"
      fi
      Log::displayError "${errorMsg} !"
    else
      echo "<error severity='error' source='warningsCount' message='${errorMsg}'/>"
    fi
    ((exitCode = 2))
  else
    if ((warningCount < optionExpectedWarningsCount)); then
      local errorMsg="you can set expected warnings count to ${warningCount} to match the current warnings count"
      if [[ "${optionFormat}" = "plain" ]]; then
        Log::displayWarning "${errorMsg}" 2> >(tee -a "${CURRENT_WARNINGS_FILE}")
        cp "${CURRENT_WARNINGS_FILE}" "${LAST_WARNINGS_FILE}"
      else
        echo "<error severity='warning' source='warningsCount' message='${errorMsg}'/>"
      fi
    fi
  fi
  if ((errorCount > 0)); then
    ((exitCode = 1))
  fi
  if [[ "${optionFormat}" = "checkstyle" ]]; then
    echo "</checkstyle>"
  fi

  return "${exitCode}"
}

run
