#!/usr/bin/env bash

%
  helpArg() {
    local withColors="$1"
    local spec=""
    if [[ "${withColors}" = "1" ]]; then
      spec+='${__HELP_OPTION_COLOR}'
    fi
    spec+="${name}"
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
      fi
      if ((max > 0)); then
        spec+=" (at most ${max} times)"
      fi
    fi
    local helpArg=""
    ((min == 0)) && helpArg+="["
    helpArg+="${spec//^[[:blank:]]/}"
    ((min == 0)) && helpArg+="]"
    echo "${helpArg}"
  }
%
<% ${argFunctionName} %>() {
  local options_parse_cmd="$1"
  shift || true

  if [[ "${options_parse_cmd}" = "parse" ]]; then
    .INCLUDE "${tplDir}/arg.parse.before.tpl"
    while (($# > 0)); do
      local options_parse_arg="$1"
      case "${options_parse_arg}" in
        -*)
          # ignore options
          ;;
        *)
          # positional arg
          .INCLUDE "${tplDir}/arg.parse.arg.tpl"
          ;;
      esac
      shift || true
    done
    .INCLUDE "${tplDir}/arg.parse.after.tpl"
  elif [[ "${options_parse_cmd}" = "help" ]]; then
    eval "$(<% ${argFunctionName} %> helpTpl)"
  elif [[ "${options_parse_cmd}" = "helpTpl" ]]; then
    # shellcheck disable=SC2016
    echo 'echo -e "  <%% helpArg "1" %>"'
    % if [[ -z "${help}" ]]; then
        echo "echo '    No help available'"
    % else
        echo "echo '    <% ${help} %>'"
    % fi
  elif [[ "${options_parse_cmd}" = "variableName" ]]; then
    echo "<% ${variableName} %>"
  elif [[ "${options_parse_cmd}" = "type" ]]; then
    echo "<% ${type} %>"
  elif [[ "${options_parse_cmd}" = "variableType" ]]; then
    echo "<% ${variableType} %>"
  elif [[ "${options_parse_cmd}" = "helpArg" ]]; then
    echo "<%% helpArg "0" %>"
  elif [[ "${options_parse_cmd}" = "oneLineHelp" ]]; then
    echo "Argument <% ${variableName} %> min <% ${min} %> min <% ${max} %> authorizedValues '<% ${authorizedValues} %>' regexp '<% ${regexp} %>'"
  elif [[ "${options_parse_cmd}" = "min" ]]; then
    echo "<% ${min} %>"
  elif [[ "${options_parse_cmd}" = "max" ]]; then
    echo "<% ${max} %>"
  elif [[ "${options_parse_cmd}" = "export" ]]; then
    export type="<% ${type} %>"
    export variableName="<% ${variableName} %>"
    export variableType="<% ${variableType} %>"
    export name="<% ${name} %>"
    export min="<% ${min} %>"
    export max="<% ${max} %>"
    export authorizedValues="<% ${authorizedValues} %>"
    export regexp="<% ${regexp} %>"
  else
    Log::displayError "Argument command invalid: '${options_parse_cmd}'"
    return 1
  fi
}
