#!/usr/bin/env bash

Options::optionVarName() {
  local cmd="$1"
  shift || true

  if [[ "${cmd}" = "parse" ]]; then
    varName="0"
    local -i options_parse_optionParsedCountVarName
    ((options_parse_optionParsedCountVarName = 0)) || true
    while (($# > 0)); do
      local options_parse_arg="$1"
      case "${options_parse_arg}" in
        --var)
          varName="1"
          if ((options_parse_optionParsedCountVarName >= 1)); then
            Log::displayError "Option ${options_parse_arg} - Maximum number of option occurrences reached(1)"
            return 1
          fi
          ;;
        *)
          # ignore
          ;;
      esac
      shift || true
    done
    export varName
  elif [[ "${cmd}" = "help" ]]; then
    eval "$(Options::optionVarName helpTpl)"
  elif [[ "${cmd}" = "oneLineHelp" ]]; then
    echo "Option varName --var variableType Boolean min 0 max 1 authorizedValues '' regexp ''"
  elif [[ "${cmd}" = "helpTpl" ]]; then
    # shellcheck disable=SC2016
    echo 'echo -n -e "  ${__HELP_OPTION_COLOR}"'
    echo 'echo -n "--var"'
    # shellcheck disable=SC2016
    echo 'echo -n -e "${__HELP_NORMAL}"'
    echo "echo -n -e ' (optional)'"
    echo "echo -n -e ' (at most 1 times)'"
    echo 'echo'
    echo "echo '    No help available'"
  elif [[ "${cmd}" = "variableName" ]]; then
    echo "varName"
  elif [[ "${cmd}" = "type" ]]; then
    echo "Option"
  elif [[ "${cmd}" = "variableType" ]]; then
    echo "Boolean"
  elif [[ "${cmd}" = "alts" ]]; then
    echo '--var'
  elif [[ "${cmd}" = "helpAlt" ]]; then
    echo '[--var]'
  elif [[ "${cmd}" = "groupId" ]]; then
    group id
  elif [[ "${cmd}" = "export" ]]; then
    export type="Option"
    export variableType="Boolean"
    export variableName="varName"
    export offValue="0"
    export onValue="1"
    export defaultValue=""
    export min="0"
    export max="1"
    export authorizedValues=""
    export alts=("--var")
  else
    Log::displayError "Option command invalid: '${cmd}'"
    return 1
  fi
}
