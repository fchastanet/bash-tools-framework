% if [[ -n "${authorizedValues}" ]]; then
if [[ ! "${options_parse_arg}" =~ <% ${authorizedValues} %> ]]; then
  Log::displayError "Argument <% ${name} %> - value '${options_parse_arg}' is not part of authorized values(<% ${authorizedValues} %>)"
  return 1
fi
% fi
% if [[ -n "${regexp}" ]]; then
if [[ ! "${options_parse_arg}" =~ <% ${regexp} %> ]]; then
  Log::displayError "Argument <% ${name} %> - value '${options_parse_arg}' doesn't match the regular expression(<% ${regexp} %>)"
  return 1
fi
% fi
% if (( max > 0 )); then
if ((options_parse_argParsedCount<% ${variableName^} %> >= <% ${max} %>)); then
  Log::displayError "Argument <% ${name} %> - Maximum number of argument occurrences reached(<% ${max} %>)"
  return 1
fi
% fi
((++options_parse_argParsedCount<% ${variableName^} %>))
% if [[ "${variableType}" = "String" ]]; then
<% ${variableName} %>="${options_parse_arg}"
% else
<% ${variableName} %>+=("${options_parse_arg}")
% fi
% if [[ -n "${callback}" ]]; then
  % if [[ "${variableType}" = "StringArray" ]]; then
  <% ${callback} %> "${<% ${variableName} %>[@]}" -- "${@:2}"
  % else
  <% ${callback} %> "${<% ${variableName} %>}" -- "${@:2}"
  % fi
% fi
