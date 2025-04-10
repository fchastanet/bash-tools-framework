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
  local defaultEnvFile
  defaultEnvFile="$(Env::createDefaultEnvFile)" || return 1
  configFiles+=("${defaultEnvFile}")
  if [[ -n "${BASH_FRAMEWORK_ENV_FILES[0]+1}" ]]; then
    # BASH_FRAMEWORK_ENV_FILES is an array
    configFiles+=("${BASH_FRAMEWORK_ENV_FILES[@]}")
  fi
  if [[ -f "${FRAMEWORK_ROOT_DIR}/.framework-config" ]]; then
    configFiles+=("${FRAMEWORK_ROOT_DIR}/.framework-config")
  fi
  local localFrameworkConfigFile
  BASH_FRAMEWORK_DISPLAY_LEVEL="${__LEVEL_INFO}" \
    BASH_FRAMEWORK_LOG_LEVEL="${__LEVEL_OFF}" \
    Conf::loadNearestFile ".framework-config" localFrameworkConfigFile "$(pwd)" || true
  if [[ -f "${localFrameworkConfigFile}" ]]; then
    configFiles+=("${localFrameworkConfigFile}")
  fi
  configFiles+=("${optionEnvFiles[@]}")
  configFiles+=("${defaultFiles[@]}")

  while IFS='' read -r file; do
    # shellcheck source=/src/Env/createDefaultEnvFile.sh
    CURRENT_LOADED_ENV_FILE="${file}" source "${file}" || {
      Log::displayError "while loading config file: ${file}"
      return 1
    }
  done < <(printf '%s\n' "${configFiles[@]}" | awk '!x[$0]++')
}
