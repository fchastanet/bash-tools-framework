% if [[ "${variableType}" = "Boolean" ]]; then
<% ${variableName} %>="<% ${offValue} %>"
% elif [[ -n "${defaultValue}" ]]; then
<% ${variableName} %>="<% ${defaultValue} %>"
% fi
% if ((min > 0 || max > 0)); then
local -i options_parse_optionParsedCount<% ${variableName^} %>
((options_parse_optionParsedCount<% ${variableName^} %> = 0)) || true
% fi
