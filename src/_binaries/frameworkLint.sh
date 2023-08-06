#!/usr/bin/env bash
# BIN_FILE=${ROOT_DIR}/bin/frameworkLint

.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/_header.tpl"

CONFIG_FILENAME="${ROOT_DIR}/.framework-config"
FORMAT="plain"
DEFAULT_ARGS=(-f plain)
HELP="$(
  cat <<EOF
${__HELP_TITLE}Synopsis:${__HELP_NORMAL} This framework linter

${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME} [-h|--help] displays this help and exits
${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME} [-f|--format <checkstyle,plain>] [--verbose|-v]

${__HELP_TITLE}Description:${__HELP_NORMAL}
Lint files of the current repository
- check if all namespace::functions are existing in the framework
- check that function defined in a .sh is correctly named
- check each function has a bats file associated

${__HELP_TITLE}Options:${__HELP_NORMAL}
  -f|--format <checkstyle,plain>  define output format of this command
  -v|--verbose display more information about processed files
  --src-dir|-s <srcDir> provide the directory where to find the functions source code.
    Prefer using .framework-config file

.INCLUDE "$(dynamicTemplateDir _includes/author.tpl)"
EOF
)"

FRAMEWORK_FUNCTIONS_IGNORE_REGEXP=^$
NON_FRAMEWORK_FILES_REGEXP=^$
FRAMEWORK_FILES_FUNCTION_MATCHING_IGNORE_REGEXP=^$
FRAMEWORK_SRC_DIRS=()

if (($# == 0)); then
  set -- "${DEFAULT_ARGS[@]}"
fi

declare args
args="$(getopt -l help,,format:,src-dir: -o hs:f: -- "$@" 2>/dev/null)" || true
eval set -- "${args}"

while true; do
  case $1 in
    -h | --help)
      echo -e "${HELP}"
      exit 0
      ;;
    -f | --format)
      shift || true
      if ! Array::contains "$1" "checkstyle" "plain"; then
        Log::fatal "format option invalid"
      fi
      FORMAT="$1"
      ;;
    --src-dir | -s)
      shift || true
      if [[ ! -d "$1" ]]; then
        Log::fatal "Directory '$1' does not exists"
      fi
      FRAMEWORK_SRC_DIRS+=("$(realpath --physical "$1")")
      ;;
    --)
      shift || true
      break
      ;;
    *)
      # ignore
      ;;
  esac
  shift || true
done

BASH_FRAMEWORK_INITIALIZED=0 Env::load

# load .framework-config
# shellcheck disable=SC2034
configFile=""
# shellcheck source=/.framework-config
Framework::loadConfig configFile "${ROOT_DIR}" || Log::fatal "error while loading .framework-config file"

checkEachFunctionHasSrcFile() {
  local file="$1"
  if [[ "${file}" =~ .bats$ ]]; then
    Log::displaySkipped "checkEachFunctionHasSrcFile - File ${file} - bats file"
    return 0
  fi
  if grep -q -E "${FRAMEWORK_FILES_FUNCTION_MATCHING_IGNORE_REGEXP}" <<<"${file}"; then
    Log::displaySkipped "checkEachFunctionHasSrcFile - File ${file} - rule FRAMEWORK_FILES_FUNCTION_MATCHING_IGNORE_REGEXP matches in ${CONFIG_FILENAME}"
    return 0
  fi
  readarray -t functionsToImport < <(
    Filters::commentLines "${file}" |
      Filters::bashFrameworkFunctions |
      awk '{$1=$1};1' |
      sort |
      uniq || true
  )
  for functionToImport in "${functionsToImport[@]}"; do
    if echo "${functionToImport}" | grep -q -E "${FRAMEWORK_FUNCTIONS_IGNORE_REGEXP}"; then
      Log::displaySkipped "checkEachFunctionHasSrcFile - File ${file} - Function ${functionToImport} rule FRAMEWORK_FUNCTIONS_IGNORE_REGEXP matches in ${CONFIG_FILENAME}"
      continue
    fi
    local fileNameToImport
    fileNameToImport="$(echo "${functionToImport}" | sed -E 's#::#/#g').sh"

    local found=0
    for srcDir in "${FRAMEWORK_SRC_DIRS[@]}"; do
      if [[ -f "${srcDir}/${fileNameToImport}" ]]; then
        found=1
      fi
    done
    if [[ "${found}" = "0" ]]; then
      if [[ "${FORMAT}" = "plain" ]]; then
        Log::displayError "checkEachFunctionHasSrcFile - File ${file} - Function ${functionToImport} - does not have a matching source file ${fileNameToImport} in any source directories specified"
      else
        echo "<error severity='error' source='checkEachFunctionHasSrcFile' message='Function ${functionToImport} does not have a matching source file ${fileNameToImport} in any source directories specified'/>"
      fi
      return 1
    fi
  done
}

getRelativeSrcDir() {
  File::relativeToDir "${FRAMEWORK_SRC_DIRS[0]}" "${ROOT_DIR}"
}

deduceBashFunctionFromSrcFile() {
  local srcFile="$1"
  local result="${srcFile%.sh}"
  result="${srcFile/$(getRelativeSrcDir)//}"
  echo "${result//\//::}"
}

checkEachSrcFileHasBatsFile() {
  local file="$1"
  if [[ ! "${file}" =~ .sh$ ]]; then
    Log::displaySkipped "checkEachSrcFileHasBatsFile - File ${file} - no suffix .sh"
    return 0
  fi
  if [[ ! "${file}" =~ ^$(getRelativeSrcDir) ]]; then
    Log::displaySkipped "checkEachSrcFileHasBatsFile - File ${file} - src directory not declared in ${CONFIG_FILENAME}"
    return 0
  fi
  if deduceBashFunctionFromSrcFile "${file}" | grep -q -E "${FRAMEWORK_FUNCTIONS_IGNORE_REGEXP}"; then
    Log::displaySkipped "checkEachSrcFileHasBatsFile - File ${file} - matching function name matches FRAMEWORK_FUNCTIONS_IGNORE_REGEXP defined in ${CONFIG_FILENAME}"
    return 0
  fi
  local batsFile="${file%.*}.bats"
  if [[ ! -f "${ROOT_DIR}/${batsFile}" ]]; then
    if [[ "${FORMAT}" = "plain" ]]; then
      Log::displayWarning "checkEachSrcFileHasBatsFile - File '${file}' - missing bats file '${batsFile}'"
    else
      echo "<error severity='warning' source='checkEachSrcFileHasBatsFile' message='missing bats file '${batsFile}'/>"
    fi
    ((++warningCount))
  fi
}

# search for at least one function that is matching the filename
checkEachSrcFileHasOneFunctionCorrectlyNamed() {
  local srcFile="$1"
  if [[ "${srcFile}" =~ ${NON_FRAMEWORK_FILES_REGEXP} ]]; then
    Log::displaySkipped "srcFileHasOneFunctionCorrectlyNamed - File ${srcFile} - rule NON_FRAMEWORK_FILES_REGEXP matches in ${CONFIG_FILENAME}"
    return 0
  fi
  if grep -q -E "${FRAMEWORK_FILES_FUNCTION_MATCHING_IGNORE_REGEXP}" <<<"${srcFile}"; then
    Log::displaySkipped "srcFileHasOneFunctionCorrectlyNamed - File ${srcFile} - rule FRAMEWORK_FILES_FUNCTION_MATCHING_IGNORE_REGEXP matches in ${CONFIG_FILENAME}"
    return 0
  fi

  local foundFunctionMatching=0
  local expectedFunctionName currentFunction
  local file="${srcFile#src/}"
  expectedFunctionName="$(sed -E 's#/#::#g' <<<"${file%.sh}")"
  if echo "${expectedFunctionName}" | grep -q -E "${FRAMEWORK_FUNCTIONS_IGNORE_REGEXP}"; then
    Log::displaySkipped "srcFileHasOneFunctionCorrectlyNamed - File ${srcFile} - Function ${expectedFunctionName} - rule FRAMEWORK_FUNCTIONS_IGNORE_REGEXP matches in ${CONFIG_FILENAME}"
    return 0
  fi

  while IFS='' read -r currentFunction; do
    if [[ "${currentFunction}" = "${expectedFunctionName}" ]]; then
      foundFunctionMatching=1
    fi
  done < <(sed -E -n 's#^([^([:blank:]]+)\(\)[[:blank:]]*\{#\1#p' "${srcFile}")

  if [[ "${foundFunctionMatching}" = "0" ]]; then
    if [[ "${FORMAT}" = "plain" ]]; then
      Log::displayWarning "srcFileHasOneFunctionCorrectlyNamed - File ${srcFile} - no function named '${expectedFunctionName}'"
    else
      echo "<error severity='warning' source='srcFileHasOneFunctionCorrectlyNamed' message='Should contain a function named ${expectedFunctionName}'/>"
    fi
    ((++warningCount))
    return 0
  fi
}

((errorCount = 0)) || true
((warningCount = 0)) || true
if [[ "${FORMAT}" = "checkstyle" ]]; then
  echo "<?xml version='1.0' encoding='UTF-8'?>"
  echo "<checkstyle>"
fi
export -f File::detectBashFile
export -f Assert::bashFile

# shellcheck disable=SC2016
while IFS='' read -r file; do
  if [[ "${FORMAT}" = "checkstyle" ]]; then
    echo "<file name='${file}'>"
  fi
  Log::displayInfo "Checking file ${file}"
  checkEachFunctionHasSrcFile "${file}" "$@" || ((++errorCount))
  checkEachSrcFileHasOneFunctionCorrectlyNamed "${file}" "$@" || ((++errorCount))
  checkEachSrcFileHasBatsFile "${file}" "$@" || ((++errorCount))

  if [[ "${FORMAT}" = "checkstyle" ]]; then
    echo "</file>"
  fi
done < <(
  git ls-files --exclude-standard |
    xargs -L 1 -n 1 -I@ bash -c 'File::detectBashFile "@"' ||
    true
)

# shellcheck disable=SC2154
while IFS='' read -r file; do
  if [[ "${FORMAT}" = "plain" ]]; then
    Log::displayWarning "fileExistence - File ${file} does not exist, git renamed file ?"
  else
    echo "<file name='${file}'>"
    echo "<error severity='warning' source='fileExistence' message='file does not exist, git renamed file ?'/>"
    echo "</file>"
  fi
  ((++warningCount))
done < <(cat "${missingBashFileList}" 2>/dev/null || true)

if [[ "${FORMAT}" = "checkstyle" ]]; then
  echo "</checkstyle>"
fi
if ((errorCount > 0 || warningCount > 0)); then
  if [[ "${FORMAT}" = "plain" ]]; then
    Log::displayError "${errorCount} errors/${warningCount} warnings found !"
  fi
  if ((errorCount > 0)); then
    exit 1
  fi
else
  Log::displaySuccess "No error found !"
fi
