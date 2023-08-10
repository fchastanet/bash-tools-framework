#!/usr/bin/env bash

# lazy initialization
declare -g BASH_FRAMEWORK_CACHED_ENV_FILE
declare -g BASH_FRAMEWORK_DEFAULT_ENV_FILE

# load variables in order(from less specific to more specific) from :
# - ${FRAMEWORK_ROOT_DIR}/src/Env/testsData/.env file
# - ${FRAMEWORK_ROOT_DIR}/conf/.env file if exists
# - ~/.env file if exists
# - ~/.bash-tools/.env file if exists
# - BASH_FRAMEWORK_ENV_FILEPATH=<fullPathToEnvFile or empty if no file to be loaded>
Env::load() {
  if [[ "${BASH_FRAMEWORK_INITIALIZED:-0}" = "1" ]]; then
    return 0
  fi
  BASH_FRAMEWORK_CACHED_ENV_FILE="$(mktemp -p "${TMPDIR:-/tmp}" -t "env_vars.XXXXXXX")"
  BASH_FRAMEWORK_DEFAULT_ENV_FILE="$(mktemp -p "${TMPDIR:-/tmp}" -t "default_env_file.XXXXXXX")"
  # shellcheck source=src/Env/testsData/.env
  (
    echo "BASH_FRAMEWORK_LOG_LEVEL=${BASH_FRAMEWORK_LOG_LEVEL:-0}"
    echo "BASH_FRAMEWORK_DISPLAY_LEVEL=${BASH_FRAMEWORK_DISPLAY_LEVEL:-3}"
    echo "BASH_FRAMEWORK_LOG_FILE=${BASH_FRAMEWORK_LOG_FILE:-${FRAMEWORK_ROOT_DIR}/logs/${SCRIPT_NAME}.log}"
    echo "BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION=${BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION:-5}"
  ) >"${BASH_FRAMEWORK_DEFAULT_ENV_FILE}"

  (
    # reset temp file
    echo >"${BASH_FRAMEWORK_CACHED_ENV_FILE}"

    # list .env files that need to be loaded
    local -a files=()
    if [[ -f "${BASH_FRAMEWORK_DEFAULT_ENV_FILE}" ]]; then
      files+=("${BASH_FRAMEWORK_DEFAULT_ENV_FILE}")
    fi
    if [[ -f "${FRAMEWORK_ROOT_DIR}/conf/.env" && -r "${FRAMEWORK_ROOT_DIR}/conf/.env" ]]; then
      files+=("${FRAMEWORK_ROOT_DIR}/conf/.env")
    fi
    if [[ -f "${HOME}/.env" && -r "${HOME}/.env" ]]; then
      files+=("${HOME}/.env")
    fi
    local file
    for file in "$@"; do
      if [[ -f "${file}" && -r "${file}" ]]; then
        files+=("${file}")
      fi
    done
    # import custom .env file
    if [[ -n "${BASH_FRAMEWORK_ENV_FILEPATH+xxx}" ]]; then
      # load BASH_FRAMEWORK_ENV_FILEPATH
      if [[ -f "${BASH_FRAMEWORK_ENV_FILEPATH}" && -r "${BASH_FRAMEWORK_ENV_FILEPATH}" ]]; then
        files+=("${BASH_FRAMEWORK_ENV_FILEPATH}")
      else
        Log::displayWarning "env file not not found - ${BASH_FRAMEWORK_ENV_FILEPATH}"
      fi
    fi

    # add all files added as parameters
    files+=("$@")

    # source each file in order
    local file
    for file in "${files[@]}"; do
      # shellcheck source=src/Env/testsData/.env
      source "${file}" || {
        Log::displayWarning "Cannot load '${file}'"
      }
    done

    # copy only the variables to the tmp file
    local varName overrideVarName
    while IFS=$'\n' read -r varName; do
      overrideVarName="OVERRIDE_${varName}"
      if [[ -z ${!overrideVarName+xxx} ]]; then
        echo "${varName}='${!varName}'" >>"${BASH_FRAMEWORK_CACHED_ENV_FILE}"
      else
        # variable is overridden
        echo "${varName}='${!overrideVarName}'" >>"${BASH_FRAMEWORK_CACHED_ENV_FILE}"
      fi

      # using awk deduce all variables that need to be copied in tmp file
      #   from less specific file to the most
    done < <(awk -F= '!a[$1]++' "${files[@]}" | grep -v '^$\|^\s*\#' | cut -d= -f1)
  ) || exit 1

  # ensure all sourced variables will be exported
  set -o allexport

  # Finally load the temp file to make the variables available in current script
  # shellcheck source=src/Env/testsData/.env
  source "${BASH_FRAMEWORK_CACHED_ENV_FILE}"

  set +o allexport
  BASH_FRAMEWORK_INITIALIZED=1
}
