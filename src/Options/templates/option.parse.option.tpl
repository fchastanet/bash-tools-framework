<%% Array::join ' | ' "${alts[@]}" %>)
  % if [[ "${variableType}" = "Boolean" ]]; then
    # shellcheck disable=SC2034
    <% ${variableName} %>="<% ${onValue} %>"
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
  % fi
  % if (( max > 0 )); then
  if ((options_parse_optionParsedCount<% ${variableName^} %> >= <% ${max} %>)); then
    Log::displayError "Command ${SCRIPT_NAME} - Option ${options_parse_arg} - Maximum number of option occurrences reached(<% ${max} %>)"
    return 1
  fi
  % fi
  ((++options_parse_optionParsedCount<% ${variableName^} %>))
  % if [[ "${variableType}" = "String" ]]; then
  # shellcheck disable=SC2034
  <% ${variableName} %>="$1"
  % elif [[ "${variableType}" = "StringArray" ]]; then
  <% ${variableName} %>+=("$1")
  % fi
  % for callback in "${callbacks[@]}"; do
    % if [[ "${variableType}" = "StringArray" ]]; then
    <% ${callback} %> "${options_parse_arg}" "${<% ${variableName} %>[@]}"
    % elif [[ "${variableType}" = "String" ]]; then
    <% ${callback} %> "${options_parse_arg}" "${<% ${variableName} %>}"
    % else
    <% ${callback} %> "${options_parse_arg}"
    % fi
  % done
  % for everyOptionCallback in "${everyOptionCallbacks[@]}"; do
    # shellcheck disable=SC2317
    % if [[ "${variableType}" = "StringArray" ]]; then
    <% ${everyOptionCallback} %> "<% ${variableName} %>" "${options_parse_arg}" "${<% ${variableName} %>[@]}" || true
    % else
    <% ${everyOptionCallback} %> "<% ${variableName} %>" "${options_parse_arg}" "${<% ${variableName} %>}" || true
    % fi
  % done
  ;;
