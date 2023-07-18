#!/usr/bin/env bash
# BIN_FILE=${ROOT_DIR}/bin/frameworkLint

.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/_header.tpl"

CONFIG_FILENAME="${ROOT_DIR}/.framework-config"
FORMAT="plain"
DEFAULT_ARGS=(-f checkstyle)
HELP="$(
  cat <<EOF
${__HELP_TITLE}Synopsis:${__HELP_NORMAL} This framework linter

${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME} [-h|--help] displays this help and exits
${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME} [-f|--format <checkstyle,plain>]

${__HELP_TITLE}Description:${__HELP_NORMAL}
Lint files of the current repository
- check if all namespace::functions are existing in the framework
- check that function defined in a .sh is correctly named

${__HELP_TITLE}Options:${__HELP_NORMAL}
  -f|--format <checkstyle,plain>  define output format of this command
  --src-dir|-s <srcDir> provide the directory where to find the functions source code.
      By default current src directory is used also.

.INCLUDE "$(dynamicTemplateDir _includes/author.tpl)"
EOF
)"

FRAMEWORK_FUNCTIONS_IGNORE_REGEXP=^$
NON_FRAMEWORK_FILES_REGEXP=^$
FRAMEWORK_FILES_FUNCTION_MATCHING_IGNORE_REGEXP=^$
FRAMEWORK_SRC_DIRS=()

# load .framework-config
# shellcheck disable=SC2034
configFile=""
# shellcheck source=/.framework-config
Framework::loadConfig configFile "${ROOT_DIR}" || Log::fatal "error while loading .framework-config file"

if (($# == 0)); then
  set -- "${DEFAULT_ARGS[@]}"
fi

declare args
args="$(getopt -l help,format:,src-dir: -o hs:f: -- "$@" 2>/dev/null)" || true
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

# add src dir by default
FRAMEWORK_SRC_DIRS+=("${ROOT_DIR}/src")

checkEachFunctionHasSrcFile() {
  local file="$1"
  readarray -t functionsToImport < <(
    Filters::bashCommentLines "${file}" |
      Filters::bashFrameworkFunctions |
      awk '{$1=$1};1' |
      sort |
      uniq || true
  )
  for functionToImport in "${functionsToImport[@]}"; do
    if echo "${functionToImport}" | grep -q -E "${FRAMEWORK_FUNCTIONS_IGNORE_REGEXP}"; then
      Log::displaySkipped "Function ${functionToImport} ignored, because of rule defined in ${CONFIG_FILENAME}"
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
        Log::displayError "The function ${functionToImport} called in ${file} does not have a matching source file ${fileNameToImport} in any source directories specified"
      else
        echo "<error severity='error' message='Function ${functionToImport} does not have a matching source file ${fileNameToImport}  in any source directories specified'/>"
      fi
      return 1
    fi
  done
}

# search for at least one function that is matching the filename
checkEachSrcFileHasOneFunctionCorrectlyNamed() {
  local srcFile="$1"
  if echo "${srcFile}" | grep -q -E "${FRAMEWORK_FILES_FUNCTION_MATCHING_IGNORE_REGEXP}"; then
    return 0
  fi
  local foundFunctionMatching=0
  local expectedFunctionName currentFunction
  local file="${srcFile#src/}"
  expectedFunctionName="$(echo "${file%.sh}" | sed -E 's#/#::#g')"
  if echo "${expectedFunctionName}" | grep -q -E "${FRAMEWORK_FUNCTIONS_IGNORE_REGEXP}"; then
    Log::displaySkipped "Function ${expectedFunctionName} ignored, because of rule defined in ${CONFIG_FILENAME}"
    return 0
  fi

  while IFS='' read -r currentFunction; do
    if [[ "${currentFunction}" = "${expectedFunctionName}" ]]; then
      foundFunctionMatching=1
    fi
  done < <(sed -E -n 's#^([^([:blank:]]+)\(\)[[:blank:]]*\{#\1#p' "${srcFile}")

  if [[ "${foundFunctionMatching}" = "0" ]]; then
    if [[ "${FORMAT}" = "plain" ]]; then
      Log::displayWarning "File ${srcFile} does not contain any function named '${expectedFunctionName}'"
    else
      echo "<error severity='warning' message='Should contain a function named ${expectedFunctionName}'/>"
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

# shellcheck disable=SC2016
while IFS='' read -r file; do
  if [[ "${FORMAT}" = "checkstyle" ]]; then
    echo "<file name='${file}'>"
  fi

  checkEachFunctionHasSrcFile "${file}" "$@" || ((++errorCount))
  checkEachSrcFileHasOneFunctionCorrectlyNamed "${file}" "$@" || ((++errorCount))

  if [[ "${FORMAT}" = "checkstyle" ]]; then
    echo "</file>"
  fi
done < <(
  git ls-files --exclude-standard |
    grep -E -v -e "${NON_FRAMEWORK_FILES_REGEXP}" |
    xargs -L 1 -n 1 -I@ bash -c 'File::detectBashFile "@"' ||
    true
)

# shellcheck disable=SC2154
while IFS='' read -r file; do
  if [[ "${FORMAT}" = "plain" ]]; then
    Log::displayWarning "File ${file} does not exist, git renamed file ?"
  else
    echo "<file name='${file}'>"
    echo "<error severity='warning' message='file does not exist, git renamed file ?'/>"
    echo "</file>"
  fi
  ((++warningCount))
done < <(cat "${missingBashFileList}")

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
