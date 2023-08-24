#!/usr/bin/env bash

Options::optionVarName() {
  local cmd="$1"
  shift || true

  if [[ "${cmd}" = "parse" ]]; then
    varName="0"
    local -i optionParsedCount
    ((optionParsedCount = 0)) || true
    while (($# > 0)); do
      local arg="$1"
      case "${arg}" in
        --var | -v)
          varName="1"
          ;;
        *)
          # ignore
          ;;
      esac
      shift || true
    done
    export varName
  elif [[ "${cmd}" = "help" ]]; then
    echo -n -e "${__HELP_EXAMPLE}  --var, -v"
    echo -n -e " (optional)"
    echo -n -e ' (at most 1 times)'
    echo -e "${__HELP_NORMAL}"
    echo '    No help available'
  else
    Log::displayError "Option command invalid: '${cmd}'"
    return 1
  fi
}
