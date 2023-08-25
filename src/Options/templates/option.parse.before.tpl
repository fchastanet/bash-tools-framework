% if [[ "${type}" = "Boolean" ]]; then
<% ${variableName} %>="<% ${offValue} %>"
% elif [[ -n "${defaultValue}" ]]; then
<% ${variableName} %>=<% ${defaultValue} %>
% fi
% if ((min > 0 || max > 0)); then
local -i optionParsedCount<% ${variableName^} %>
((optionParsedCount<% ${variableName^} %> = 0)) || true
% fi
