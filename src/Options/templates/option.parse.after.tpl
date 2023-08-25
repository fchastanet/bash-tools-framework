% if ((min > 0)); then
if ((optionParsedCount<% ${variableName^} %> < <% ${min} %>)); then
  Log::displayError "Option '<% ${alts[0]} %>' should be provided at least <% ${min} %> time(s)"
  return 1
fi
% fi
export <% ${variableName} %>
