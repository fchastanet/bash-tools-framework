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
        --var)
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
    export varName
  elif [[ "${cmd}" = "help" ]]; then
    echo -n -e "${__HELP_EXAMPLE}  --var"
    echo -n -e " (optional)"
    echo -n -e ' (at most 1 times)'
    echo -e "${__HELP_NORMAL}"
    echo '    No help available'
  else
    Log::displayError "Option command invalid: '${cmd}'"
    return 1
  fi
}
