#!/usr/bin/env bash

<% ${functionName} %>() {
  local cmd="$1"
  shift || true

  if [[ "${cmd}" = "parse" ]]; then
    .INCLUDE "${tplDir}/option.parse.before.tpl"
    while (($# > 0)); do
      local options_parse_arg="$1"
      case "${options_parse_arg}" in
        .INCLUDE "${tplDir}/option.parse.option.tpl"
        *)
          # ignore
          ;;
      esac
      shift || true
    done
    .INCLUDE "${tplDir}/option.parse.after.tpl"
  elif [[ "${cmd}" = "help" ]]; then
    eval "$(<% ${functionName} %> helpTpl)"
  elif [[ "${cmd}" = "oneLineHelp" ]]; then
    echo "Option <% ${variableName} %> <%% Array::join '|' "${alts[@]}" %> variableType <% ${variableType} %> min <% ${min} %> max <% ${max} %> authorizedValues '<% ${authorizedValues} %>' regexp '<% ${regexp} %>'"
  elif [[ "${cmd}" = "helpTpl" ]]; then
    %
      altStr='${__HELP_OPTION_COLOR}'
      altStr+="$(Array::join '${__HELP_NORMAL}, ${__HELP_OPTION_COLOR}' "${alts[@]}")"
      if [[ "${variableType}" != "Boolean" ]]; then
        altStr+=" <${helpValueName}>"
      fi
      altStr+='${__HELP_NORMAL}'
      if ((min == 1 && max == 1)); then
        altStr+=' (mandatory)'
      else
        if ((min > 0)); then
          altStr+=" (at least ${min} times)"
        else
          altStr+=' (optional)'
        fi
        if ((max > 0)); then
          altStr+=" (at most ${max} times)"
        fi
      fi
    %
    # shellcheck disable=SC2016
    echo 'printf "  %b\n" "<% ${altStr} %>"'
    % if [[ -z "${help}" ]]; then
        echo "echo '    No help available'"
    % elif [[ $(type -t "${help}") == "function" ]]; then
      echo "echo -e \"    \$(Array::wrap ' ' 76 4 \$(<% ${help} %>))\""
    % else
      echo "local -a helpArray"
      % printf -v helpEscaped '%q' "${help}"
      echo "IFS=' ' read -r -a helpArray <<< <% ${helpEscaped} %>"
      echo $'echo -e "    $(Array::wrap " " 76 4 "${helpArray[@]}")"'
    % fi
    % if [[ -n "${defaultValue}" ]]; then
        echo "echo '    Default value: <% ${defaultValue} %>'"
    % fi
  elif [[ "${cmd}" = "variableName" ]]; then
    echo "<% ${variableName} %>"
  elif [[ "${cmd}" = "type" ]]; then
    echo "<% ${type} %>"
  elif [[ "${cmd}" = "variableType" ]]; then
    echo "<% ${variableType} %>"
  elif [[ "${cmd}" = "alts" ]]; then
    % for alt in "${alts[@]}"; do
    echo '<% ${alt} %>'
    % done
  elif [[ "${cmd}" = "helpAlt" ]]; then
    %
      if [[ "${variableType}" = "Boolean" ]]; then
        helpAlt="[$(Array::join '|' "${alts[@]}")]"
      else
        helpAlt=""
        ((min == 0)) && helpAlt+="["
        helpAlt+="$(Array::join '|' "${alts[@]}")"
        helpAlt+=" <${helpValueName}>"
        ((min == 0)) && helpAlt+="]"
      fi
    %
    echo '<% ${helpAlt%, } %>'
  elif [[ "${cmd}" = "groupId" ]]; then
    % if [[ -z "${group}" ]]; then
    echo "__default"
    % else
    <% ${group} %> id
    % fi
  elif [[ "${cmd}" = "export" ]]; then
    export type="<% ${type} %>"
    export variableType="<% ${variableType} %>"
    export variableName="<% ${variableName} %>"
    export offValue="<% ${offValue} %>"
    export onValue="<% ${onValue} %>"
    export defaultValue="<% ${defaultValue} %>"
    export callbacks=(<%% Array::join " " "${callbacks[@]}" %>)
    export min="<% ${min} %>"
    export max="<% ${max} %>"
    export authorizedValues="<% ${authorizedValues} %>"
    % exportAlts="$(printf ' "%s"' "${alts[@]}")"
    export alts=(<% ${exportAlts:1} %>)
  else
    Log::displayError "Command ${SCRIPT_NAME} - Option command invalid: '${cmd}'"
    return 1
  fi
}
