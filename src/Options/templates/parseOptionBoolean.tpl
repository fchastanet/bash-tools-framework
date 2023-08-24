#!/usr/bin/env bash

<% ${optionFunctionName} %>() {
  local cmd="$1"
  shift || true

  if [[ "${cmd}" = "parse" ]]; then
    <% ${variableName} %>="<% ${offValue} %>"
    while (($# > 0)); do
      local arg="$1"
      case "${arg}" in
        <%% Array::join ' | ' "${alts[@]}" %>)
          <% ${variableName} %>="<% ${onValue} %>"
          ;;
        *)
          # ignore
          ;;
      esac
      shift || true
    done
    export <% ${variableName} %>
  elif [[ "${cmd}" = "help" ]]; then
    echo -n -e "${__HELP_EXAMPLE}  <%% Array::join ', ' "${alts[@]}" %>"
    %
      if [[ "${mandatory}" = "1" ]]; then
        echo '    echo -e " (mandatory)${__HELP_NORMAL}"'
      else
        echo '    echo -e " (optional)${__HELP_NORMAL}"'
      fi
      if [[ -z "${help}" ]]; then
        echo "    echo '    No help available'"
      else
        echo "    echo '    ${help}'"
      fi
    %
  else
    Log::displayError "Option command invalid: '${cmd}'"
    return 1
  fi
}
