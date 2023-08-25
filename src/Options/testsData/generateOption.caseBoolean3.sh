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
    eval "$(Options::optionVarName helpTpl)"
  elif [[ "${cmd}" = "helpTpl" ]]; then
    # shellcheck disable=SC2016
    echo 'echo -n -e "  ${__HELP_OPTION_COLOR}"'
    echo 'echo -n "--var, -v"'
    # shellcheck disable=SC2016
    echo 'echo -n -e "${__HELP_NORMAL}"'
    echo "echo -n -e ' (optional)'"
    echo "echo -n -e ' (at most 1 times)'"
    echo 'echo'
    echo "echo '    No help available'"
  elif [[ "${cmd}" = "type" ]]; then
    echo "Boolean"
  elif [[ "${cmd}" = "helpAlt" ]]; then
    echo '[--var|-v]'
  else
    Log::displayError "Option command invalid: '${cmd}'"
    return 1
  fi
}
