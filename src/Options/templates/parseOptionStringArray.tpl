#!/usr/bin/env bash

<% ${optionFunctionName} %>() {
  local cmd="$1"
  shift || true

  if [[ "${cmd}" = "parse" ]]; then
    % if [[ -n "${defaultValue}" ]]; then
    <% ${variableName} %>=<% ${defaultValue} %>
    % fi
    local -i optionParsedCount
    ((optionParsedCount = 0)) || true
    while (($# > 0)); do
      local arg=$1
      case "${arg}" in
        <%% Array::join ' | ' "${alts[@]}" %>)
          shift
          if (($# == 0)); then
            Log::displayError "Option ${arg} - a value needs to be specified"
            return 1
          fi
          % if [[ -n "${authorizedValues}" ]]; then
          if [[ ! "$1" =~ <% ${authorizedValues} %> ]]; then
            Log::displayError "Option ${arg} - value '$1' is not part of authorized values(<% ${authorizedValues} %>)"
            return 1
          fi
          % fi
          % if [[ -n "${max}" ]]; then
          if ((optionParsedCount >= <% ${max} %>)); then
            Log::displayError "Option ${arg} - Maximum number of option occurrences reached(<% ${max} %>)"
            return 1
          fi
          % fi
          ((++optionParsedCount))
          % if [[ "${type}" = "String" ]]; then
          <% ${variableName} %>="$1"
          % else
          <% ${variableName} %>+=("$1")
          % fi
          ;;
        *)
          # ignore
          ;;
      esac
      shift || true
    done
    % if [[ -n "${min}" ]] && (( min > 0)); then
    if ((optionParsedCount < <% ${min} %>)); then
      Log::displayError "Option '<% ${alts[0]} %>' should be provided at least <% ${min} %> time(s)"
      return 1
    fi
    % fi
    export <% ${variableName} %>
  elif [[ "${cmd}" = "help" ]]; then
    echo -n -e "${__HELP_EXAMPLE}  <%% Array::join ', ' "${alts[@]}" %>"
    %
      if ((min == 1 && max == 1)); then
        echo "    echo -n -e ' (mandatory)'"
      else
        if [[ -n "${min}" ]] && ((min > 0)); then
          echo "    echo -n -e ' (at least ${min} times)'"
        else
          echo '    echo -n -e " (optional)"'
        fi
        if [[ -n "${max}" ]]; then
          echo "    echo -n -e ' (at most ${max} times)'"
        fi
      fi
      echo '    echo -e "${__HELP_NORMAL}"'
      if [[ -z "${help}" ]]; then
        echo "    echo '    No help available'"
      else
        echo "    echo '    ${help}'"
      fi
      if [[ -n "${defaultValue}" ]]; then
        echo "    echo '    Default value: <% ${defaultValue} %>'"
      fi
    %
  else
    Log::displayError "Option command invalid: '${cmd}'"
    return 1
  fi
}
