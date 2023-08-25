#!/usr/bin/env bash

<% ${optionFunctionName} %>() {
  local cmd="$1"
  shift || true

  if [[ "${cmd}" = "parse" ]]; then
    % if [[ "${type}" = "Boolean" ]]; then
    <% ${variableName} %>="<% ${offValue} %>"
    % elif [[ -n "${defaultValue}" ]]; then
    <% ${variableName} %>=<% ${defaultValue} %>
    % fi
    local -i optionParsedCount
    ((optionParsedCount = 0)) || true
    while (($# > 0)); do
      local arg="$1"
      case "${arg}" in
        <%% Array::join ' | ' "${alts[@]}" %>)
          % if [[ "${type}" = "Boolean" ]]; then
            <% ${variableName} %>="<% ${onValue} %>"
          % else
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
          % fi
          ;;
        *)
          # ignore
          ;;
      esac
      shift || true
    done
    % if [[ -n "${min}" ]] && ((min > 0)); then
    if ((optionParsedCount < <% ${min} %>)); then
      Log::displayError "Option '<% ${alts[0]} %>' should be provided at least <% ${min} %> time(s)"
      return 1
    fi
    % fi
    export <% ${variableName} %>
  elif [[ "${cmd}" = "help" ]]; then
    eval "$(<% ${optionFunctionName} %> helpTpl)"
  elif [[ "${cmd}" = "helpTpl" ]]; then
    # shellcheck disable=SC2016
    echo 'echo -n -e "  ${__HELP_OPTION_COLOR}"'
    echo 'echo -n "<%% Array::join ", " "${alts[@]}" %>"'
    % if [[ "${type}" != "Boolean" ]]; then
      echo "echo -n ' <String>'"
    % fi
    # shellcheck disable=SC2016
    echo 'echo -n -e "${__HELP_NORMAL}"'
    % if ((min == 1 && max == 1)); then
      echo "echo -n -e ' (mandatory)'"
    % else
      % if [[ -n "${min}" ]] && ((min > 0)); then
        echo "echo -n -e ' (at least <% ${min} %> times)'"
      % else
        echo "echo -n -e ' (optional)'"
      % fi
      % if [[ -n "${max}" ]]; then
        echo "echo -n -e ' (at most <% ${max} %> times)'"
      % fi
    % fi
    echo 'echo'
    % if [[ -z "${help}" ]]; then
        echo "echo '    No help available'"
    % else
        echo "echo '    <% ${help} %>'"
    % fi
    % if [[ -n "${defaultValue}" ]]; then
        echo "echo '    Default value: <% ${defaultValue} %>'"
    % fi
  elif [[ "${cmd}" = "type" ]]; then
    echo "<% ${type} %>"
  elif [[ "${cmd}" = "helpAlt" ]]; then
    %
      if [[ "${type}" = "Boolean" ]]; then
        helpAlt="[$(Array::join '|' "${alts[@]}")]"
      else
        helpAlt=""
        ((min == 0)) && helpAlt+="["
        helpAlt+="$(Array::join '|' "${alts[@]}")"
        ((min == 0)) && helpAlt+=" <String>]"
      fi
    %
    echo '<% ${helpAlt%, } %>'
  else
    Log::displayError "Option command invalid: '${cmd}'"
    return 1
  fi
}
