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
          if ((optionParsedCount >= 1)); then
            Log::displayError "Option ${arg} - Maximum number of option occurrences reached(1)"
            return 1
          fi
          ((++optionParsedCount))
          varName="$1"
          ;;
        *)
          # ignore
          ;;
      esac
      shift || true
    done
    if ((optionParsedCount < 1)); then
      Log::displayError "Option '--var' should be provided at least 1 time(s)"
      return 1
    fi
    export varName
  elif [[ "${cmd}" = "help" ]]; then
    echo -n -e "${__HELP_EXAMPLE}  --var, -v"
    echo -n -e ' (mandatory)'
    echo -e "${__HELP_NORMAL}"
    echo '    super help'
  else
    Log::displayError "Option command invalid: '${cmd}'"
    return 1
  fi
}
