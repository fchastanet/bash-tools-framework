#!/usr/bin/env bash

# @description ensure env files are loaded
# @arg $@ list of default files to load at the end
# @exitcode 1 if one of env files fails to load
# @stderr diagnostics information is displayed
# shellcheck disable=SC2120
Env::requireLoad() {
  local -a defaultFiles=("$@")
  # get list of possible config files
  local -a configFiles=()
  if [[ -n "${BASH_FRAMEWORK_ENV_FILES[0]+1}" ]]; then
    # BASH_FRAMEWORK_ENV_FILES is an array
    configFiles+=("${BASH_FRAMEWORK_ENV_FILES[@]}")
  fi
  if [[ -f "$(pwd)/.framework-config" ]]; then
    configFiles+=("$(pwd)/.framework-config")
  fi
  if [[ -f "${FRAMEWORK_ROOT_DIR}/.framework-config" ]]; then
    configFiles+=("${FRAMEWORK_ROOT_DIR}/.framework-config")
  fi
  if [[ -n "${optionBashFrameworkConfig}" && -f "${optionBashFrameworkConfig}" ]]; then
    # shellcheck disable=SC2034
    configFiles+=("${optionBashFrameworkConfig}")
  fi
  configFiles+=("${optionEnvFiles[@]}")
  configFiles+=("${defaultFiles[@]}")

  for file in "${configFiles[@]}"; do
    # shellcheck source=/.framework-config
    CURRENT_LOADED_ENV_FILE="${file}" source "${file}" || {
      Log::displayError "while loading config file: ${file}"
      return 1
    }
  done
}
