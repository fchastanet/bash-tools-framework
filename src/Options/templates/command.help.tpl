Array::wrap " " 80 2 <%% echo '"${__HELP_TITLE_COLOR}Description:${__RESET_COLOR}"' %> "<% ${help} %>"
% echo '    echo'

%# ------------------------------------------
%# usage section
%# ------------------------------------------
%
args=($(printf '%s' "${commandName}"))
((${#optionList[@]} > 0)) && args+=("[OPTIONS]")
((${#argumentList[@]} > 0)) && args+=("[ARGUMENTS]")

%
Array::wrap " " 80 2 <%% echo '"${__HELP_TITLE_COLOR}USAGE:${__RESET_COLOR}"' %><%% printf ' "%s"' "${args[@]}" %>
%
optionsAltList=()
for option in "${optionList[@]}"; do
  optionsAltList+=("$("${option}" "helpAlt")")
done
if ((${#optionList[@]} > 0)); then
%
Array::wrap " " 80 2 <%% echo '"${__HELP_TITLE_COLOR}USAGE:${__RESET_COLOR}"' %> \
  <%% printf '"%s"' "${commandName}" %> \
  <%%  printf '"%s" ' "${optionsAltList[@]}" %>
% fi
%# ------------------------------------------
%# options section
%# ------------------------------------------
%
if ((${#optionList[@]} > 0)); then
  echo '    echo'
  local option
  echo $'    echo -e "${__HELP_TITLE_COLOR}OPTIONS:${__RESET_COLOR}"'
  for option in ${optionList[@]}; do
    "${option}" helpTpl | sed 's/^/    /'
  done
fi
%
%# ------------------------------------------
%# arguments section
%# ------------------------------------------
%
if ((${#argumentList[@]} > 0)); then
  echo '    echo'
  echo $'    echo -e "${__HELP_TITLE_COLOR}ARGUMENTS:${__RESET_COLOR}"'
  local arg
  for arg in "${argumentList[@]}"; do
    "${arg}" helpTpl | sed 's/^/    /'
  done
fi
%
%# ------------------------------------------
%# version section
%# ------------------------------------------
%
if [[ -n "${version}" ]]; then
  echo '    echo'
  echo $'    echo -e "${__HELP_TITLE_COLOR}Version:" <% ${version} %>${__RESET_COLOR}'
fi
%
%# ------------------------------------------
%# author section
%# ------------------------------------------
%
if [[ -n "${author}" ]]; then
  echo 'echo'
  echo $'    echo -e "${__HELP_TITLE_COLOR}AUTHOR:${__RESET_COLOR}"'
  echo "    echo '<% ${author} %>'"
fi
%
%# ------------------------------------------
%# license section
%# ------------------------------------------
%
if [[ -n "${license}" ]]; then
  echo 'echo'
  echo $'    echo -e "${__HELP_TITLE_COLOR}LICENSE:${__RESET_COLOR}"'
  echo "    echo '<% ${license} %>'"
fi
%
%# ------------------------------------------
%# copyright section
%# ------------------------------------------
%
if [[ -n "${copyright}" ]]; then
  echo '    echo'
  echo "    echo '<% ${copyright} %>'"
fi
%
