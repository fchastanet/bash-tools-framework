#!/usr/bin/env bash

## Initialize some default variables
## List of variables
## * BASH_FRAMEWORK_INITIALIZED=1 lazy initialization
##
## default tests/data/.env file is loaded
##
## then all these variables can be overridden by a .env file that will be searched in the following directories
## in this order (stop on first file found):
## * __BASH_FRAMEWORK_CALLING_SCRIPT: upper directory
## * ~/ : home path
## * ~/.bash-tools : home path .bash-tools
## alternatively you can force a given .env file to be loaded using
## BASH_FRAMEWORK_ENV_FILEPATH=<fullPathToEnvFile or empty if no file to be loaded>
Framework::loadEnv() {
  # import default .env file
  # shellcheck source=tests/data/.env
  source "${ROOT_DIR}/tests/data/.env" || exit 1

  # import custom .env file
  if [[ -z "${BASH_FRAMEWORK_ENV_FILEPATH+xxx}" ]]; then
    # BASH_FRAMEWORK_ENV_FILEPATH not defined
    if [[ -f "${HOME}/.bash-tools/.env" ]]; then
      # shellcheck source=tests/data/.env
      source "${HOME}/.bash-tools/.env" || exit 1
    elif [[ -f "${HOME}/.env" ]]; then
      # shellcheck source=tests/data/.env
      source "${HOME}/.env" || exit 1
    fi
  elif [[ -z "${BASH_FRAMEWORK_ENV_FILEPATH}" ]]; then
    # BASH_FRAMEWORK_ENV_FILEPATH defined but empty - nothing to do
    true
  else
    # load BASH_FRAMEWORK_ENV_FILEPATH
    [[ ! -f "${BASH_FRAMEWORK_ENV_FILEPATH}" ]] &&
      Log::fatal "env file not not found - ${BASH_FRAMEWORK_ENV_FILEPATH}"
    # shellcheck source=tests/data/.env
    source "${BASH_FRAMEWORK_ENV_FILEPATH}"
  fi

  Log::loadEnv

  export BASH_FRAMEWORK_INITIALIZED=1

  set +o allexport
}
