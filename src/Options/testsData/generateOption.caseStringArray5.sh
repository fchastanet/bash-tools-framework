#!/usr/bin/env bash

Options::option() {
  local cmd="$1"
  shift || true

  if [[ "${cmd}" = "parse" ]]; then
    local -i options_parse_optionParsedCountVarName
    ((options_parse_optionParsedCountVarName = 0)) || true
    while (($# > 0)); do
      local options_parse_arg="$1"
      case "${options_parse_arg}" in
        --var | -v)
          shift
          if (($# == 0)); then
            Log::displayError "Command ${SCRIPT_NAME} - Option ${options_parse_arg} - a value needs to be specified"
            return 1
          fi
          if [[ ! "$1" =~ value1|value2|value3 ]]; then
            Log::displayError "Command ${SCRIPT_NAME} - Option ${options_parse_arg} - value '$1' is not part of authorized values(value1|value2|value3)"
            return 1
          fi
          if ((options_parse_optionParsedCountVarName >= 3)); then
            Log::displayError "Command ${SCRIPT_NAME} - Option ${options_parse_arg} - Maximum number of option occurrences reached(3)"
            return 1
          fi
          ((++options_parse_optionParsedCountVarName))
          varName+=("$1")
          ;;
        *)
          # ignore
          ;;
      esac
      shift || true
    done
    if ((options_parse_optionParsedCountVarName < 2)); then
      Log::displayError "Command ${SCRIPT_NAME} - Option '--var' should be provided at least 2 time(s)"
      return 1
    fi
    export varName
  elif [[ "${cmd}" = "help" ]]; then
    eval "$(Options::option helpTpl)"
  elif [[ "${cmd}" = "oneLineHelp" ]]; then
    echo "Option varName --var|-v variableType StringArray min 2 max 3 authorizedValues 'value1|value2|value3' regexp ''"
  elif [[ "${cmd}" = "helpTpl" ]]; then
    # shellcheck disable=SC2016
    echo 'printf "  %b\n" "${__HELP_OPTION_COLOR}--var${__HELP_NORMAL}, ${__HELP_OPTION_COLOR}-v <String>${__HELP_NORMAL} (at least 2 times) (at most 3 times)"'
    echo "echo -e \"    $(Array::wrap " " 75 0 "super help")\""
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
  elif [[ "${cmd}" = "groupId" ]]; then
    echo "__default"
  elif [[ "${cmd}" = "export" ]]; then
    export type="Option"
    export variableType="StringArray"
    export variableName="varName"
    export offValue=""
    export onValue=""
    export defaultValue=""
    export callbacks=()
    export min="2"
    export max="3"
    export authorizedValues="value1|value2|value3"
    export alts=("--var" "-v")
  else
    Log::displayError "Command ${SCRIPT_NAME} - Option command invalid: '${cmd}'"
    return 1
  fi
}
