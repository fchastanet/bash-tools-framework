#!/usr/bin/env bash

Options::option() {
  local cmd="$1"
  shift || true

  if [[ "${cmd}" = "parse" ]]; then
    varName="0"
    local -i options_parse_optionParsedCountVarName
    ((options_parse_optionParsedCountVarName = 0)) || true
    while (($# > 0)); do
      local options_parse_arg="$1"
      case "${options_parse_arg}" in
        --var | -v)
          varName="1"
          if ((options_parse_optionParsedCountVarName >= 1)); then
            Log::displayError "Command ${SCRIPT_NAME} - Option ${options_parse_arg} - Maximum number of option occurrences reached(1)"
            return 1
          fi
          ((++options_parse_optionParsedCountVarName))
          ;;
        *)
          # ignore
          ;;
      esac
      shift || true
    done
    export varName
  elif [[ "${cmd}" = "help" ]]; then
    eval "$(Options::option helpTpl)"
  elif [[ "${cmd}" = "oneLineHelp" ]]; then
    echo "Option varName --var|-v variableType Boolean min 0 max 1 authorizedValues '' regexp ''"
  elif [[ "${cmd}" = "helpTpl" ]]; then
    # shellcheck disable=SC2016
    echo 'printf "  %b\n" "${__HELP_OPTION_COLOR}--var${__HELP_NORMAL}, ${__HELP_OPTION_COLOR}-v${__HELP_NORMAL} (optional) (at most 1 times)"'
    echo "local -a helpArray"
    echo "IFS=' ' read -r -a helpArray <<< super\ help"
    echo $'echo -e "    $(Array::wrap " " 76 4 "${helpArray[@]}")"'
  elif [[ "${cmd}" = "variableName" ]]; then
    echo "varName"
  elif [[ "${cmd}" = "type" ]]; then
    echo "Option"
  elif [[ "${cmd}" = "variableType" ]]; then
    echo "Boolean"
  elif [[ "${cmd}" = "alts" ]]; then
    echo '--var'
    echo '-v'
  elif [[ "${cmd}" = "helpAlt" ]]; then
    echo '[--var|-v]'
  elif [[ "${cmd}" = "groupId" ]]; then
    echo "__default"
  elif [[ "${cmd}" = "export" ]]; then
    export type="Option"
    export variableType="Boolean"
    export variableName="varName"
    export offValue="0"
    export onValue="1"
    export defaultValue=""
    export callbacks=()
    export min="0"
    export max="1"
    export authorizedValues=""
    export alts=("--var" "-v")
  else
    Log::displayError "Command ${SCRIPT_NAME} - Option command invalid: '${cmd}'"
    return 1
  fi
}
