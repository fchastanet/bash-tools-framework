#!/usr/bin/env bash

# @description get list of env files to load
# in order to make them available for Env::requireLoad
# @env BASH_FRAMEWORK_ENV_FILES String[] list of env files that should be loaded
# @exitcode 1 if one of the env file cannot be generated
# @exitcode 2 if one of the env file is not a file or readable
# @stdout the env files asked to be loaded
# @stderr diagnostic information on failure
# @see https://github.com/fchastanet/bash-tools-framework/blob/master/FrameworkDoc.md#config_file_order
Env::getOrderedConfFiles() {
  local -a configFiles=()

  if [[ -n "${BASH_FRAMEWORK_ENV_FILES[0]+1}" ]]; then
    # BASH_FRAMEWORK_ENV_FILES is an array
    configFiles+=("${BASH_FRAMEWORK_ENV_FILES[@]}")
  fi

  local defaultEnvFile
  defaultEnvFile="$(Env::createDefaultEnvFile)" || return 1
  configFiles+=("${defaultEnvFile}")

  local file
  for file in "${configFiles[@]}"; do
    if [[ ! -f "${file}" || ! -r "${file}" ]]; then
      Log::displayError "One of the config file is not available '${file}'"
      return 2
    fi
    echo "${file}"
  done
}
