#!/usr/bin/env bash

# lazy initialization
declare -g BASH_FRAMEWORK_INITIALIZED="0"

declare BASH_FRAMEWORK_CACHED_ENV_FILE
BASH_FRAMEWORK_CACHED_ENV_FILE="$(mktemp -p "${TMPDIR:-/tmp}" -t "env_vars.XXXXXXX")"

declare BASH_FRAMEWORK_DEFAULT_ENV_FILE
BASH_FRAMEWORK_DEFAULT_ENV_FILE="$(mktemp -p "${TMPDIR:-/tmp}" -t "default_env_file.XXXXXXX")"

# shellcheck source=tests/data/.env
cat >"${BASH_FRAMEWORK_DEFAULT_ENV_FILE}" <<'EOF'
BASH_FRAMEWORK_LOG_LEVEL=0
BASH_FRAMEWORK_DISPLAY_LEVEL=3
BASH_FRAMEWORK_LOG_FILE=${ROOT_DIR}/logs/${SCRIPT_NAME}.log
BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION=5
EOF

# load variables in order(from less specific to more specific) from :
# - ${ROOT_DIR}/tests/data/.env file
# - ${ROOT_DIR}/.env file if exists
# - ~/.env file if exists
# - ~/.bash-tools/.env file if exists
# - BASH_FRAMEWORK_ENV_FILEPATH=<fullPathToEnvFile or empty if no file to be loaded>
Env::load() {
  if [[ "${BASH_FRAMEWORK_INITIALIZED}" = "1" ]]; then
    return 0
  fi
  (
    # reset temp file
    echo >"${BASH_FRAMEWORK_CACHED_ENV_FILE}"

    # ensure all sourced variables will be exported
    set -o allexport

    # 1. list .env files that need to be loaded
    local -a files=(
      "${BASH_FRAMEWORK_DEFAULT_ENV_FILE}"
    )
    if [[ -f "${ROOT_DIR}/conf/.env" && -r "${ROOT_DIR}/conf/.env" ]]; then
      files+=("${ROOT_DIR}/conf/.env")
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
        Log::fatal "env file not not found - ${BASH_FRAMEWORK_ENV_FILEPATH}"
      fi
    fi

    # 2. source each file in order
    local file
    for file in "${files[@]}"; do
      # shellcheck source=tests/data/.env
      source "${file}" || {
        Log::displayWarning "Cannot load '${file}'"
      }
    done

    # 4. copy only the variables to the tmp file
    local varName
    while IFS=$'\n' read -r varName; do
      echo "${varName}='${!varName}'" >>"${BASH_FRAMEWORK_CACHED_ENV_FILE}"

      # 3. using awk deduce all variables that need to be copied in tmp file
      #    from less specific file to the most
    done < <(awk -F= '!a[$1]++' "${files[@]}" | grep -v '^$\|^\s*\#' | cut -d= -f1)
    set +o allexport
  )

  # Finally load the temp file to make the variables available in current script
  set -o allexport
  # shellcheck source=tests/data/.env
  source "${BASH_FRAMEWORK_CACHED_ENV_FILE}"

  export BASH_FRAMEWORK_INITIALIZED=1

  set +o allexport
}
