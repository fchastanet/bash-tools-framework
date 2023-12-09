#!/usr/bin/env bash

%
  helpOpt() {
    local withColors="$1"
    local spec=""
    if [[ "${withColors}" = "1" ]]; then
      spec+='${__HELP_OPTION_COLOR}'
      spec+="$(Array::join '${__HELP_NORMAL}, ${__HELP_OPTION_COLOR}' "${alts[@]}")"
    else
      spec+="$(Array::join ', ' "${alts[@]}")"
    fi
    if [[ "${variableType}" != "Boolean" ]]; then
      spec+=" <${helpValueName}>"
    fi
    if [[ "${withColors}" = "1" ]]; then
      spec+='${__HELP_NORMAL}'
    fi
    if ((max == 1)); then
      spec+=' {single}'
      if ((min == 1)); then
        spec+=' (mandatory)'
      fi
    else
      spec+=' {list}'
      if ((min > 0)); then
        spec+=" (at least ${min} times)"
      else
        spec+=' (optional)'
      fi
      if ((max > 0)); then
        spec+=" (at most ${max} times)"
      fi
    fi
    local helpOpt=""
    helpOpt+="${spec//^[[:blank:]]/}"
    echo "${helpOpt}"
  }
%
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
    # shellcheck disable=SC2016
    echo 'echo -e "  <%% helpOpt "1" %>"'
    .INCLUDE "${tplDir}/helpArg.tpl"
    % if [[ -n "${defaultValue}" ]]; then
        echo "echo '    Default value: <% ${defaultValue} %>'"
    % fi
    % if [[ -n "${authorizedValues}" ]]; then
        echo "echo '    Possible values: <% ${authorizedValues} %>'"
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
    export variableName="<% ${variableName} %>"
    export variableType="<% ${variableType} %>"
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
