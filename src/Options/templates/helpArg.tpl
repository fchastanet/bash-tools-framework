% if [[ -z "${help}" ]]; then
    echo "echo '    No help available'"
% elif [[ $(type -t "${help}") == "function" ]]; then
  echo "local -a helpArray"
  echo "# shellcheck disable=SC2054,SC2206"
  echo 'mapfile -t helpArray < <(<% ${help} %>)'
  echo $'echo -e "    $(Array::wrap " " 76 4 "${helpArray[@]}")"'
% else
  echo "local -a helpArray"
  % printf -v helpEscaped '%q' "${help}"
  echo "# shellcheck disable=SC2054"
  echo "helpArray=(<% ${helpEscaped} %>)"
  echo $'echo -e "    $(Array::wrap " " 76 4 "${helpArray[@]}")"'
% fi
