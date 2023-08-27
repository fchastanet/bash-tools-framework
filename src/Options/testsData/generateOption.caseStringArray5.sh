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
          if [[ ! "$1" =~ value1|value2|value3 ]]; then
            Log::displayError "Option ${arg} - value '$1' is not part of authorized values(value1|value2|value3)"
            return 1
          fi
          if ((optionParsedCountVarName >= 3)); then
            Log::displayError "Option ${arg} - Maximum number of option occurrences reached(3)"
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
    if ((optionParsedCountVarName < 2)); then
      Log::displayError "Option '--var' should be provided at least 2 time(s)"
      return 1
    fi
    export varName
  elif [[ "${cmd}" = "help" ]]; then
    eval "$(Options::optionVarName helpTpl)"
  elif [[ "${cmd}" = "oneLineHelp" ]]; then
    echo "Option varName --var|-v variableType StringArray min 2 max 3 authorizedValues 'value1|value2|value3' regexp ''"
  elif [[ "${cmd}" = "helpTpl" ]]; then
    # shellcheck disable=SC2016
    echo 'echo -n -e "  ${__HELP_OPTION_COLOR}"'
    echo 'echo -n "--var, -v"'
    echo "echo -n ' <String>'"
    # shellcheck disable=SC2016
    echo 'echo -n -e "${__HELP_NORMAL}"'
    echo "echo -n -e ' (at least 2 times)'"
    echo "echo -n -e ' (at most 3 times)'"
    echo 'echo'
    echo "echo '    super help'"
  elif [[ "${cmd}" = "variableName" ]]; then
    echo "varName"
  elif [[ "${cmd}" = "type" ]]; then
    echo "Option"
  elif [[ "${cmd}" = "variableType" ]]; then
    echo "StringArray"
  elif [[ "${cmd}" = "alts" ]]; then
    echo '--var'
    echo '-v'
  elif [[ "${cmd}" = "helpAlt" ]]; then
    echo '--var|-v'
  elif [[ "${cmd}" = "export" ]]; then
    export type="Option"
    export variableType="StringArray"
    export variableName="varName"
    export offValue=""
    export onValue=""
    export defaultValue=""
    export min="2"
    export max="3"
    export authorizedValues="value1|value2|value3"
    export alts=("--var" "-v")
  else
    Log::displayError "Option command invalid: '${cmd}'"
    return 1
  fi
}
