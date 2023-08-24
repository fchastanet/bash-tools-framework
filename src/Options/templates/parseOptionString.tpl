#!/usr/bin/env bash

<% ${optionFunctionName} %>() {
  local cmd="$1"
  shift || true

  if [[ "${cmd}" = "parse" ]]; then
    <% ${variableName} %>="<% ${defaultValue} %>"
    local optionParsed="0"
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
          optionParsed="1"
          <% ${variableName} %>="$1"
          ;;
        *)
          # ignore
          ;;
      esac
      shift || true
    done
    % if [[ "${mandatory}" = "1" ]]; then
    if [[ "${optionParsed}" = "0" ]]; then
      Log::displayError "Option '<% ${alts[0]} %>' should be provided"
      return 1
    fi
    % fi
    export <% ${variableName} %>
  elif [[ "${cmd}" = "help" ]]; then
    echo -n -e "${__HELP_EXAMPLE}  <%% Array::join ', ' "${alts[@]}" %>"
    %
      if [[ "${mandatory}" = "1" ]]; then
        echo '    echo -e " (mandatory)${__HELP_NORMAL}"'
      else
        echo '    echo -e " (optional)${__HELP_NORMAL}"'
      fi
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
