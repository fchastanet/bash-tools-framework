#!/usr/bin/env bash

Options::optionVarName() {
  local cmd="$1"
  shift || true

  if [[ "${cmd}" = "parse" ]]; then
    local -i optionParsedCountVarName
    ((optionParsedCountVarName = 0)) || true
    while (($# > 0)); do
      local arg="$1"
      case "${arg}" in
        --var | -v)
          shift
          if (($# == 0)); then
            Log::displayError "Option ${arg} - a value needs to be specified"
            return 1
          fi
          ((++optionParsedCountVarName))
          varName+=("$1")
          ;;
        *)
          # ignore
          ;;
      esac
      shift || true
    done
    if ((optionParsedCountVarName < 1)); then
      Log::displayError "Option '--var' should be provided at least 1 time(s)"
      return 1
    fi
    export varName
  elif [[ "${cmd}" = "help" ]]; then
    eval "$(Options::optionVarName helpTpl)"
  elif [[ "${cmd}" = "helpTpl" ]]; then
    # shellcheck disable=SC2016
    echo 'echo -n -e "  ${__HELP_OPTION_COLOR}"'
    echo 'echo -n "--var, -v"'
    echo "echo -n ' <String>'"
    # shellcheck disable=SC2016
    echo 'echo -n -e "${__HELP_NORMAL}"'
    echo "echo -n -e ' (at least 1 times)'"
    echo 'echo'
    echo "echo '    super help'"
  elif [[ "${cmd}" = "variableName" ]]; then
    echo "varName"
  elif [[ "${cmd}" = "type" ]]; then
    echo "StringArray"
  elif [[ "${cmd}" = "alts" ]]; then
    echo '--var'
    echo '-v'
  elif [[ "${cmd}" = "helpAlt" ]]; then
    echo '--var|-v'
  elif [[ "${cmd}" = "export" ]]; then
    export type="StringArray"
    export variableName="varName"
    export offValue=""
    export onValue=""
    export defaultValue=""
    export min="1"
    export max=""
    export authorizedValues=""
    export alts=("--var" "-v")
  else
    Log::displayError "Option command invalid: '${cmd}'"
    return 1
  fi
}
