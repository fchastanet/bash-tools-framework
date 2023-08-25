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
    if ((optionParsedCount<% ${variableName^} %> >= <% ${max} %>)); then
      Log::displayError "Option ${arg} - Maximum number of option occurrences reached(<% ${max} %>)"
      return 1
    fi
    % fi
    ((++optionParsedCount<% ${variableName^} %>))
    % if [[ "${type}" = "String" ]]; then
    <% ${variableName} %>="$1"
    % else
    <% ${variableName} %>+=("$1")
    % fi
  % fi
  ;;
