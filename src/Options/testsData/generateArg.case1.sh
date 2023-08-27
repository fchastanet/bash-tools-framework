#!/usr/bin/env bash

Options::argVarName() {
  local cmd="$1"
  shift || true

  if [[ "${cmd}" = "parse" ]]; then
    local -i argParsedCountVarName
    ((argParsedCountVarName = 0)) || true
    while (($# > 0)); do
      local arg="$1"
      case "${arg}" in
        -*)
          # ignore options
          ;;
        *)
          # positional arg
          if ((argParsedCountVarName >= 1)); then
            Log::displayError "Argument varName - Maximum number of argument occurrences reached(1)"
            return 1
          fi
          ((++argParsedCountVarName))
          varName="$1"
          ;;
      esac
      shift || true
    done
    if ((argParsedCountVarName < 1)); then
      Log::displayError "Argument 'varName' should be provided at least 1 time(s)"
      return 1
    fi
    export varName
  elif [[ "${cmd}" = "help" ]]; then
    eval "$(Options::argVarName helpTpl)"
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
  elif [[ "${cmd}" = "helpArg" ]]; then
    echo "varName {single} (mandatory)"
  elif [[ "${cmd}" = "oneLineHelp" ]]; then
    echo "Argument varName min 1 min 1 authorizedValues '' regexp ''"
  elif [[ "${cmd}" = "min" ]]; then
    echo "1"
  elif [[ "${cmd}" = "max" ]]; then
    echo "1"
  elif [[ "${cmd}" = "export" ]]; then
    export type="Argument"
    export variableName="varName"
    export variableType="String"
    export name="varName"
    export min="1"
    export max="1"
    export authorizedValues=""
    export regexp=""
  else
    Log::displayError "Argument command invalid: '${cmd}'"
    return 1
  fi
}
