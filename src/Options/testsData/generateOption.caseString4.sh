#!/usr/bin/env bash

Options::optionVarName() {
  local cmd="$1"
  shift || true

  if [[ "${cmd}" = "parse" ]]; then
    varName=""
    local optionParsed="0"
    while (($# > 0)); do
      local arg=$1
      case "${arg}" in
        --var | -v)
          shift
          if (($# == 0)); then
            Log::displayError "Option ${arg} - a value needs to be specified"
            return 1
          fi
          optionParsed="1"
          varName="$1"
          ;;
        *)
          # ignore
          ;;
      esac
      shift || true
    done
    if [[ "${optionParsed}" = "0" ]]; then
      Log::displayError "Option '--var' should be provided"
      return 1
    fi
    export varName
  elif [[ "${cmd}" = "help" ]]; then
    echo -n -e "${__HELP_EXAMPLE}  --var, -v"
    echo -e " (mandatory)${__HELP_NORMAL}"
    echo '    super help'
  else
    Log::displayError "Option command invalid: '${cmd}'"
    return 1
  fi
}
