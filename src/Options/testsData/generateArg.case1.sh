#!/usr/bin/env bash

Options::arg() {
  local cmd="$1"
  shift || true

  if [[ "${cmd}" = "parse" ]]; then
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
          # shellcheck disable=SC2034
          varName="${options_parse_arg}"
          ;;
      esac
      shift || true
    done
    if ((options_parse_argParsedCountVarName < 1)); then
      Log::displayError "Command ${SCRIPT_NAME} - Argument 'varName' should be provided at least 1 time(s)"
      return 1
    fi
  elif [[ "${cmd}" = "help" ]]; then
    eval "$(Options::arg helpTpl)"
  elif [[ "${cmd}" = "oneLineHelp" ]]; then
    echo "Argument varName min 1 max 1 authorizedValues '' regexp ''"
  elif [[ "${cmd}" = "helpTpl" ]]; then
    # shellcheck disable=SC2016
    echo 'echo -e "  ${__HELP_OPTION_COLOR}varName${__HELP_NORMAL} {single} (mandatory)"'
    echo "echo '    No help available'"
  elif [[ "${cmd}" = "variableName" ]]; then
    echo "varName"
  elif [[ "${cmd}" = "type" ]]; then
    echo "Argument"
  elif [[ "${cmd}" = "variableType" ]]; then
    echo "String"
  elif [[ "${cmd}" = "export" ]]; then
    export type="Argument"
    export variableName="varName"
    export variableType="String"
    export name="varName"
    export min="1"
    export max="1"
    export authorizedValues=""
    export regexp=""
    export callbacks=()
  elif [[ "${cmd}" = "min" ]]; then
    echo "1"
  elif [[ "${cmd}" = "max" ]]; then
    echo "1"
  else
    Log::displayError "Command ${SCRIPT_NAME} - Argument command invalid: '${cmd}'"
    return 1
  fi
}
