#!/usr/bin/env bash

Options::optionVarName() {
  local cmd="$1"
  shift || true

  if [[ "${cmd}" = "parse" ]]; then
    local -i optionParsedCount
    ((optionParsedCount = 0)) || true
    while (($# > 0)); do
      local arg=$1
      case "${arg}" in
        --var | -v)
          shift
          if (($# == 0)); then
            Log::displayError "Option ${arg} - a value needs to be specified"
            return 1
          fi
          if [[ ! "$1" =~ value1|value2|value3 ]]; then
            Log::displayError "Option ${arg} - value '$1' is not part of authorized values(value1|value2|value3)"
            return 1
          fi
          if ((optionParsedCount >= 3)); then
            Log::displayError "Option ${arg} - Maximum number of option occurrences reached(3)"
            return 1
          fi
          ((++optionParsedCount))
          varName+=("$1")
          ;;
        *)
          # ignore
          ;;
      esac
      shift || true
    done
    if ((optionParsedCount < 2)); then
      Log::displayError "Option '--var' should be provided at least 2 time(s)"
      return 1
    fi
    export varName
  elif [[ "${cmd}" = "help" ]]; then
    echo -n -e "${__HELP_EXAMPLE}  --var, -v"
    echo -n -e ' (at least 2 times)'
    echo -n -e ' (at most 3 times)'
    echo -e "${__HELP_NORMAL}"
    echo '    super help'
  else
    Log::displayError "Option command invalid: '${cmd}'"
    return 1
  fi
}
