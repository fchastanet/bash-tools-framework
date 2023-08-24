#!/usr/bin/env bash

Options::optionVarName() {
  local cmd="$1"
  shift || true

  if [[ "${cmd}" = "parse" ]]; then
    varName="0"
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
    echo -e " (mandatory)${__HELP_NORMAL}"
    echo '    super help'
  else
    Log::displayError "Option command invalid: '${cmd}'"
    return 1
  fi
}
