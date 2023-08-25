#!/usr/bin/env bash

<% ${optionFunctionName} %>() {
  local cmd="$1"
  shift || true

  if [[ "${cmd}" = "parse" ]]; then
    .INCLUDE "${tplDir}/option.parse.before.tpl"
    while (($# > 0)); do
      local arg="$1"
      case "${arg}" in
        .INCLUDE "${tplDir}/option.parse.option.tpl"
        *)
          # ignore
          ;;
      esac
      shift || true
    done
    .INCLUDE "${tplDir}/option.parse.after.tpl"
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
  elif [[ "${cmd}" = "variableName" ]]; then
    echo "<% ${variableName} %>"
  elif [[ "${cmd}" = "type" ]]; then
    echo "<% ${type} %>"
  elif [[ "${cmd}" = "alts" ]]; then
    % for alt in "${alts[@]}"; do
    echo '<% ${alt} %>'
    % done
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
  elif [[ "${cmd}" = "export" ]]; then
    export type="<% ${type} %>"
    export variableName="<% ${variableName} %>"
    export offValue="<% ${offValue} %>"
    export onValue="<% ${onValue} %>"
    export defaultValue="<% ${defaultValue} %>"
    export min="<% ${min} %>"
    export max="<% ${max} %>"
    export authorizedValues="<% ${authorizedValues} %>"
    % exportAlts="$(printf ' "%s"' "${alts[@]}")"
    export alts=(<% ${exportAlts:1} %>)
  else
    Log::displayError "Option command invalid: '${cmd}'"
    return 1
  fi
}
