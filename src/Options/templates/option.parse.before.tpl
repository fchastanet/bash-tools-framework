% if [[ "${type}" = "Boolean" ]]; then
<% ${variableName} %>="<% ${offValue} %>"
% elif [[ -n "${defaultValue}" ]]; then
<% ${variableName} %>=<% ${defaultValue} %>
% fi
local -i optionParsedCount<% ${variableName^} %>
((optionParsedCount<% ${variableName^} %> = 0)) || true
