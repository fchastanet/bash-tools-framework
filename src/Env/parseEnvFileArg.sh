#!/usr/bin/env bash

# @description if --env-file option is parsed in arguments
# outputs the file provided after this argument to make it
# available for Env::requireLoad
# @option --env-file <file> the environment file to load
# @env BASH_FRAMEWORK_ARGV String[] list of arguments passed to the command (provided by _mandatoryHeaders.sh file)
# @exitcode 1 if Env file provided is invalid
# @stdout the env filepath asked to be loaded
# @stderr diagnostic information on failure
Env::parseEnvFileArg() {
  (
    set -- "${BASH_FRAMEWORK_ARGV[@]}" --
    while true; do
      case $1 in
        --env-file)
          shift || true
          if [[ "$1" = "--" ]]; then
            Log::displayError "Env file not provided"
            return 1
          fi
          if [[ ! -r "$1" ]]; then
            Log::displayError "Env file provided '$1' is invalid"
            return 1
          fi
          echo "$1"
          ;;
        --)
          break
          ;;
        *)
          # ignore
          ;;
      esac
      shift || true
    done
  )
}
