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
      else
        spec+=' (optional)'
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
<% ${functionName} %>() {
  local cmd="$1"
  shift || true

  if [[ "${cmd}" = "parse" ]]; then
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
  elif [[ "${cmd}" = "help" ]]; then
    eval "$(<% ${functionName} %> helpTpl)"
  elif [[ "${cmd}" = "oneLineHelp" ]]; then
    echo "Argument <% ${variableName} %> min <% ${min} %> max <% ${max} %> authorizedValues '<% ${authorizedValues} %>' regexp '<% ${regexp} %>'"
  elif [[ "${cmd}" = "helpTpl" ]]; then
    # shellcheck disable=SC2016
    echo 'echo -e "  <%% helpArg "1" %>"'
    .INCLUDE "${tplDir}/helpArg.tpl"
  elif [[ "${cmd}" = "variableName" ]]; then
    echo "<% ${variableName} %>"
  elif [[ "${cmd}" = "type" ]]; then
    echo "<% ${type} %>"
  elif [[ "${cmd}" = "variableType" ]]; then
    echo "<% ${variableType} %>"
  elif [[ "${cmd}" = "export" ]]; then
    export type="<% ${type} %>"
    export variableName="<% ${variableName} %>"
    export variableType="<% ${variableType} %>"
    export name="<% ${name} %>"
    export min="<% ${min} %>"
    export max="<% ${max} %>"
    export authorizedValues="<% ${authorizedValues} %>"
    export regexp="<% ${regexp} %>"
    export callbacks=(<%% Array::join " " "${callbacks[@]}" %>)
  elif [[ "${cmd}" = "min" ]]; then
    echo "<% ${min} %>"
  elif [[ "${cmd}" = "max" ]]; then
    echo "<% ${max} %>"
  else
    Log::displayError "Command ${SCRIPT_NAME} - Argument command invalid: '${cmd}'"
    return 1
  fi
}
