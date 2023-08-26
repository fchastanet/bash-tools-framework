% if ((min > 0)); then
if ((argParsedCount<% ${variableName^} %> < <% ${min} %>)); then
  Log::displayError "Argument '<% ${name} %>' should be provided at least <% ${min} %> time(s)"
  return 1
fi
% fi
export <% ${variableName} %>
