% if ((min > 0)); then
if ((options_parse_argParsedCount<% ${variableName^} %> < <% ${min} %>)); then
  Log::displayError "Argument '<% ${name} %>' should be provided at least <% ${min} %> time(s)"
  return 1
fi
% fi
export <% ${variableName} %>
