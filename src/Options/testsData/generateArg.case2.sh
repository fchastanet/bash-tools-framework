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
          if [[ ! "$1" =~ debug|info|warn ]]; then
            Log::displayError "Argument varName - value '$1' is not part of authorized values(debug|info|warn)"
            return 1
          fi
          if ((argParsedCountVarName >= 3)); then
            Log::displayError "Argument varName - Maximum number of argument occurrences reached(3)"
            return 1
          fi
          ((++argParsedCountVarName))
          varName+=("$1")
          ;;
      esac
      shift || true
    done
    export varName
  elif [[ "${cmd}" = "help" ]]; then
    eval "$(Options::argVarName helpTpl)"
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
  elif [[ "${cmd}" = "export" ]]; then
    export type="Argument"
    export variableName="varName"
    export variableType="StringArray"
    export name="varName"
    export min="0"
    export max="3"
    export authorizedValues="debug|info|warn"
    export regexp=""
  else
    Log::displayError "Argument command invalid: '${cmd}'"
    return 1
  fi
}
