<%% Array::join ' | ' "${alts[@]}" %>)
  % if [[ "${variableType}" = "Boolean" ]]; then
    <% ${variableName} %>="<% ${onValue} %>"
    % if (( max > 0 )); then
    if ((options_parse_optionParsedCount<% ${variableName^} %> >= <% ${max} %>)); then
      Log::displayError "Command ${SCRIPT_NAME} - Option ${options_parse_arg} - Maximum number of option occurrences reached(<% ${max} %>)"
      return 1
    fi
    % fi
  % else
    shift
    if (($# == 0)); then
      Log::displayError "Command ${SCRIPT_NAME} - Option ${options_parse_arg} - a value needs to be specified"
      return 1
    fi
    % if [[ -n "${authorizedValues}" ]]; then
    if [[ ! "$1" =~ <% ${authorizedValues} %> ]]; then
      Log::displayError "Command ${SCRIPT_NAME} - Option ${options_parse_arg} - value '$1' is not part of authorized values(<% ${authorizedValues} %>)"
      return 1
    fi
    % fi
    % if (( max > 0 )); then
    if ((options_parse_optionParsedCount<% ${variableName^} %> >= <% ${max} %>)); then
      Log::displayError "Command ${SCRIPT_NAME} - Option ${options_parse_arg} - Maximum number of option occurrences reached(<% ${max} %>)"
      return 1
    fi
    % fi
    % if ((min > 0 || max > 0)); then
    ((++options_parse_optionParsedCount<% ${variableName^} %>))
    % fi
    % if [[ "${variableType}" = "String" ]]; then
    <% ${variableName} %>="$1"
    % else
    <% ${variableName} %>+=("$1")
    % fi
  % fi
  % for callback in "${callbacks[@]}"; do
    % if [[ "${variableType}" = "StringArray" ]]; then
    <% ${callback} %> "${options_parse_arg}" "${<% ${variableName} %>[@]}"
    % else
    <% ${callback} %> "${options_parse_arg}" "${<% ${variableName} %>}"
    % fi
  % done
  ;;
