#!/usr/bin/env bash

# @description generate option parse code for boolean type
# @arg $@ args:StringArray
# @option --off-value <value> (optional) value set by default on the variable (Default: 0)
# @option --on-value <value> (optional) value set on the variable if option provided (Default: 1)
# @exitcode 1 if error during option parsing
# @stdout script file generated to parse the arguments following the rules provided
# @stderr diagnostics information is displayed
# @see Options::generateOption
Options::generateOptionBoolean() {
  # args default values
  local onValue="1"
  local offValue="0"

  while (($# > 0)); do
    case "$1" in
      --mandatory)
        Log::displaySkipped "Options::generateOptionBoolean - --mandatory is incompatible with Boolean type, ignored"
        ;;
      --on-value)
        shift || true
        if [[ -z "$1" ]]; then
          Log::displayError "Options::generateOptionBoolean - --on-value cannot be empty"
          return 1
        fi
        onValue="$1"
        ;;
      --off-value)
        shift || true
        if [[ -z "$1" ]]; then
          Log::displayError "Options::generateOptionBoolean - --off-value cannot be empty"
          return 1
        fi
        offValue="$1"
        ;;
      -*)
        Log::displayError "Options::generateOptionBoolean - invalid option '$1'"
        return 1
        ;;
      *) ;;
    esac
    shift || true
  done
  if [[ "${onValue}" = "${offValue}" ]]; then
    Log::displayError "Options::generateOptionBoolean - --on-value and --off-value cannot be equal"
    return 1
  fi

  echo "export min='0'"
  echo "export max='1'"
  echo "export onValue='${onValue}'"
  echo "export offValue='${offValue}'"
}
