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
  elif [[ "${options_parse_cmd}" = "help" ]]; then
    eval "$(Options::arg helpTpl)"
  elif [[ "${options_parse_cmd}" = "helpTpl" ]]; then
    # shellcheck disable=SC2016
    echo 'echo -e "  [${__HELP_OPTION_COLOR}varName${__HELP_NORMAL} {list} (at most 3 times)]"'
    echo "echo '    No help available'"
  elif [[ "${options_parse_cmd}" = "variableName" ]]; then
    echo "varName"
  elif [[ "${options_parse_cmd}" = "type" ]]; then
    echo "Argument"
  elif [[ "${options_parse_cmd}" = "variableType" ]]; then
    echo "StringArray"
  elif [[ "${options_parse_cmd}" = "helpArg" ]]; then
    echo "[varName {list} (at most 3 times)]"
  elif [[ "${options_parse_cmd}" = "oneLineHelp" ]]; then
    echo "Argument varName min 0 max 3 authorizedValues 'debug|info|warn' regexp ''"
  elif [[ "${options_parse_cmd}" = "min" ]]; then
    echo "0"
  elif [[ "${options_parse_cmd}" = "max" ]]; then
    echo "3"
  elif [[ "${options_parse_cmd}" = "export" ]]; then
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
    Log::displayError "Argument command invalid: '${options_parse_cmd}'"
    return 1
  fi
}
