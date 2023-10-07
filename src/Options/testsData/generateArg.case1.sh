#!/usr/bin/env bash

Options::arg() {
  local options_parse_cmd="$1"
  shift || true

  if [[ "${options_parse_cmd}" = "parse" ]]; then
    local -i options_parse_argParsedCountVarName
    ((options_parse_argParsedCountVarName = 0)) || true
    while (($# > 0)); do
      local options_parse_arg="$1"
      case "${options_parse_arg}" in
        -*)
          # ignore options
          ;;
        *)
          # positional arg
          if ((options_parse_argParsedCountVarName >= 1)); then
            Log::displayError "Command ${SCRIPT_NAME} - Argument varName - Maximum number of argument occurrences reached(1)"
            return 1
          fi
          ((++options_parse_argParsedCountVarName))
          varName="${options_parse_arg}"
          ;;
      esac
      shift || true
    done
    if ((options_parse_argParsedCountVarName < 1)); then
      Log::displayError "Command ${SCRIPT_NAME} - Argument 'varName' should be provided at least 1 time(s)"
      return 1
    fi
    export varName
  elif [[ "${options_parse_cmd}" = "help" ]]; then
    eval "$(Options::arg helpTpl)"
  elif [[ "${options_parse_cmd}" = "helpTpl" ]]; then
    # shellcheck disable=SC2016
    echo 'echo -e "  ${__HELP_OPTION_COLOR}varName${__HELP_NORMAL} {single} (mandatory)"'
    echo "echo '    No help available'"
  elif [[ "${options_parse_cmd}" = "variableName" ]]; then
    echo "varName"
  elif [[ "${options_parse_cmd}" = "type" ]]; then
    echo "Argument"
  elif [[ "${options_parse_cmd}" = "variableType" ]]; then
    echo "String"
  elif [[ "${options_parse_cmd}" = "helpArg" ]]; then
    echo "varName {single} (mandatory)"
  elif [[ "${options_parse_cmd}" = "oneLineHelp" ]]; then
    echo "Argument varName min 1 max 1 authorizedValues '' regexp ''"
  elif [[ "${options_parse_cmd}" = "min" ]]; then
    echo "1"
  elif [[ "${options_parse_cmd}" = "max" ]]; then
    echo "1"
  elif [[ "${options_parse_cmd}" = "export" ]]; then
    export type="Argument"
    export variableName="varName"
    export variableType="String"
    export name="varName"
    export min="1"
    export max="1"
    export authorizedValues=""
    export regexp=""
    export callbacks=()
  else
    Log::displayError "Argument command invalid: '${options_parse_cmd}'"
    return 1
  fi
}
