#!/usr/bin/env bash

Options::option() {
  local cmd="$1"
  shift || true

  if [[ "${cmd}" = "parse" ]]; then
    help="0"
    local -i options_parse_optionParsedCountHelp
    ((options_parse_optionParsedCountHelp = 0)) || true
    while (($# > 0)); do
      local options_parse_arg="$1"
      case "${options_parse_arg}" in
        --help | -h)
          # shellcheck disable=SC2034
          help="1"
          if ((options_parse_optionParsedCountHelp >= 1)); then
            Log::displayError "Command ${SCRIPT_NAME} - Option ${options_parse_arg} - Maximum number of option occurrences reached(1)"
            return 1
          fi
          ((++options_parse_optionParsedCountHelp))
          helpCallback "${options_parse_arg}"
          helpCallback2 "${options_parse_arg}"
          ;;
        *)
          # ignore
          ;;
      esac
      shift || true
    done
  elif [[ "${cmd}" = "help" ]]; then
    eval "$(Options::option helpTpl)"
  elif [[ "${cmd}" = "oneLineHelp" ]]; then
    echo "Option help --help|-h variableType Boolean min 0 max 1 authorizedValues '' regexp ''"
  elif [[ "${cmd}" = "helpTpl" ]]; then
    # shellcheck disable=SC2016
    echo 'echo -e "  ${__HELP_OPTION_COLOR}--help${__HELP_NORMAL}, ${__HELP_OPTION_COLOR}-h${__HELP_NORMAL} {single}"'
    echo "echo '    No help available'"
  elif [[ "${cmd}" = "variableName" ]]; then
    echo "help"
  elif [[ "${cmd}" = "type" ]]; then
    echo "Option"
  elif [[ "${cmd}" = "variableType" ]]; then
    echo "Boolean"
  elif [[ "${cmd}" = "alts" ]]; then
    echo '--help'
    echo '-h'
  elif [[ "${cmd}" = "helpAlt" ]]; then
    echo '[--help|-h]'
  elif [[ "${cmd}" = "groupId" ]]; then
    echo "__default"
  elif [[ "${cmd}" = "export" ]]; then
    export type="Option"
    export variableName="help"
    export variableType="Boolean"
    export offValue="0"
    export onValue="1"
    export defaultValue=""
    export callbacks=(helpCallback helpCallback2)
    export min="0"
    export max="1"
    export authorizedValues=""
    export alts=("--help" "-h")
  else
    Log::displayError "Command ${SCRIPT_NAME} - Option command invalid: '${cmd}'"
    return 1
  fi
}
