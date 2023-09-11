#!/usr/bin/env bash

Options::option() {
  local cmd="$1"
  shift || true

  if [[ "${cmd}" = "parse" ]]; then
    while (($# > 0)); do
      local options_parse_arg="$1"
      case "${options_parse_arg}" in
        --src-dir | -s)
          shift
          if (($# == 0)); then
            Log::displayError "Command ${SCRIPT_NAME} - Option ${options_parse_arg} - a value needs to be specified"
            return 1
          fi
          srcDirs+=("$1")
          srcDirsCallback "${options_parse_arg}" "${srcDirs[@]}"
          ;;
        *)
          # ignore
          ;;
      esac
      shift || true
    done
    export srcDirs
  elif [[ "${cmd}" = "help" ]]; then
    eval "$(Options::option helpTpl)"
  elif [[ "${cmd}" = "oneLineHelp" ]]; then
    echo "Option srcDirs --src-dir|-s variableType StringArray min 0 max -1 authorizedValues '' regexp ''"
  elif [[ "${cmd}" = "helpTpl" ]]; then
    # shellcheck disable=SC2016
    echo 'printf "  %b\n" "${__HELP_OPTION_COLOR}--src-dir${__HELP_NORMAL}, ${__HELP_OPTION_COLOR}-s <String>${__HELP_NORMAL} (optional)"'
    echo "echo '    No help available'"
  elif [[ "${cmd}" = "variableName" ]]; then
    echo "srcDirs"
  elif [[ "${cmd}" = "type" ]]; then
    echo "Option"
  elif [[ "${cmd}" = "variableType" ]]; then
    echo "StringArray"
  elif [[ "${cmd}" = "alts" ]]; then
    echo '--src-dir'
    echo '-s'
  elif [[ "${cmd}" = "helpAlt" ]]; then
    echo '[--src-dir|-s <String>]'
  elif [[ "${cmd}" = "groupId" ]]; then
    echo "__default"
  elif [[ "${cmd}" = "export" ]]; then
    export type="Option"
    export variableType="StringArray"
    export variableName="srcDirs"
    export offValue=""
    export onValue=""
    export defaultValue=""
    export callbacks=(srcDirsCallback)
    export min="0"
    export max="-1"
    export authorizedValues=""
    export alts=("--src-dir" "-s")
  else
    Log::displayError "Command ${SCRIPT_NAME} - Option command invalid: '${cmd}'"
    return 1
  fi
}
