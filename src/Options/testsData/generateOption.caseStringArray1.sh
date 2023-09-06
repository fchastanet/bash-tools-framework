#!/usr/bin/env bash

Options::option() {
  local cmd="$1"
  shift || true

  if [[ "${cmd}" = "parse" ]]; then
    while (($# > 0)); do
      local options_parse_arg="$1"
      case "${options_parse_arg}" in
        --var)
          shift
          if (($# == 0)); then
            Log::displayError "Option ${options_parse_arg} - a value needs to be specified"
            return 1
          fi
          varName+=("$1")
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
    echo "Option varName --var variableType StringArray min 0 max -1 authorizedValues '' regexp ''"
  elif [[ "${cmd}" = "helpTpl" ]]; then
    # shellcheck disable=SC2016
    echo 'echo -n -e "  ${__HELP_OPTION_COLOR}"'
    echo 'echo -n "--var"'
    echo "echo -n ' <String>'"
    # shellcheck disable=SC2016
    echo 'echo -n -e "${__HELP_NORMAL}"'
    echo "echo -n -e ' (optional)'"
    echo 'echo'
    echo "echo '    No help available'"
  elif [[ "${cmd}" = "variableName" ]]; then
    echo "varName"
  elif [[ "${cmd}" = "type" ]]; then
    echo "Option"
  elif [[ "${cmd}" = "variableType" ]]; then
    echo "StringArray"
  elif [[ "${cmd}" = "alts" ]]; then
    echo '--var'
  elif [[ "${cmd}" = "helpAlt" ]]; then
    echo '[--var <String>]'
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
    export min="0"
    export max="-1"
    export authorizedValues=""
    export alts=("--var")
  else
    Log::displayError "Option command invalid: '${cmd}'"
    return 1
  fi
}
