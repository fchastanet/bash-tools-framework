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
          if [[ ! "${options_parse_arg}" =~ debug|info|warn ]]; then
            Log::displayError "Command ${SCRIPT_NAME} - Argument varName - value '${options_parse_arg}' is not part of authorized values(debug|info|warn)"
            return 1
          fi
          if ((options_parse_argParsedCountVarName >= 3)); then
            Log::displayError "Command ${SCRIPT_NAME} - Argument varName - Maximum number of argument occurrences reached(3)"
            return 1
          fi
          ((++options_parse_argParsedCountVarName))
          # shellcheck disable=SC2034
          varName+=("${options_parse_arg}")
          ;;
      esac
      shift || true
    done
  elif [[ "${cmd}" = "help" ]]; then
    eval "$(Options::arg helpTpl)"
  elif [[ "${cmd}" = "helpTpl" ]]; then
    # shellcheck disable=SC2016
    echo 'echo -e "  [${__HELP_OPTION_COLOR}varName${__HELP_NORMAL} {list} (at most 3 times)]"'
    echo "echo '    No help available'"
  elif [[ "${cmd}" = "variableName" ]]; then
    echo "varName"
  elif [[ "${cmd}" = "type" ]]; then
    echo "Argument"
  elif [[ "${cmd}" = "variableType" ]]; then
    echo "StringArray"
  elif [[ "${cmd}" = "helpArg" ]]; then
    echo "[varName {list} (at most 3 times)]"
  elif [[ "${cmd}" = "oneLineHelp" ]]; then
    echo "Argument varName min 0 max 3 authorizedValues 'debug|info|warn' regexp ''"
  elif [[ "${cmd}" = "min" ]]; then
    echo "0"
  elif [[ "${cmd}" = "max" ]]; then
    echo "3"
  elif [[ "${cmd}" = "export" ]]; then
    export type="Argument"
    export variableName="varName"
    export variableType="StringArray"
    export name="varName"
    export min="0"
    export max="3"
    export authorizedValues="debug|info|warn"
    export regexp=""
    export callbacks=()
  else
    Log::displayError "Argument command invalid: '${cmd}'"
    return 1
  fi
}
