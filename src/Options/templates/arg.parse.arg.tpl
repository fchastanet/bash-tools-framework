% if [[ -n "${authorizedValues}" ]]; then
if [[ ! "$1" =~ <% ${authorizedValues} %> ]]; then
  Log::displayError "Argument <% ${name} %> - value '$1' is not part of authorized values(<% ${authorizedValues} %>)"
  return 1
fi
% fi
% if [[ -n "${regexp}" ]]; then
if [[ ! "$1" =~ <% ${regexp} %> ]]; then
  Log::displayError "Argument <% ${name} %> - value '$1' doesn't match the regular expression(<% ${regexp} %>)"
  return 1
fi
% fi
% if (( max > 0 )); then
if ((argParsedCount<% ${variableName^} %> >= <% ${max} %>)); then
  Log::displayError "Argument <% ${name} %> - Maximum number of argument occurrences reached(<% ${max} %>)"
  return 1
fi
% fi
((++argParsedCount<% ${variableName^} %>))
% if [[ "${variableType}" = "String" ]]; then
<% ${variableName} %>="$1"
% else
<% ${variableName} %>+=("$1")
% fi
