echo -e "$(Array::wrap " " 80 0 <%% echo -e '"${__HELP_TITLE_COLOR}Description:${__RESET_COLOR}"' %> "<% ${help} %>")"
% echo '    echo'

%# ------------------------------------------
%# usage section
%# ------------------------------------------
%
args=($(printf '%s' "${commandName}"))
((${#optionList[@]} > 0)) && args+=("[OPTIONS]")
((${#argumentList[@]} > 0)) && args+=("[ARGUMENTS]")

%
echo -e "$(Array::wrap " " 80 2 <%% echo '"${__HELP_TITLE_COLOR}USAGE:${__RESET_COLOR}"' %><%% printf ' "%s"' "${args[@]}" %>)"
%
optionsAltList=()
for option in "${optionList[@]}"; do
  optionsAltList+=("$("${option}" "helpAlt")")
done
if ((${#optionList[@]} > 0)); then
%
echo -e "$(Array::wrap " " 80 2 <%% echo '"${__HELP_TITLE_COLOR}USAGE:${__RESET_COLOR}"' %> \
  <%% printf '"%s"' "${commandName}" %> \
  <%%  printf '"%s" ' "${optionsAltList[@]}" | sed -E 's/[ ]*$//' %>)"
% fi
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
%# options section
%# ------------------------------------------
%
if ((${#optionList[@]} > 0)); then
  echo '    echo'
  local option
  local previousGroupId=""
  local groupId
  for option in ${optionList[@]}; do
    groupId="$("${option}" groupId)"
    if [[ "${groupId}" != "${previousGroupId}" ]]; then
      if [[ "${groupId}" = "__default" ]]; then
        echo $'    echo -e "${__HELP_TITLE_COLOR}OPTIONS:${__RESET_COLOR}"'
      else
        "${groupId}" helpTpl
      fi
    fi
    "${option}" helpTpl | sed 's/^/    /'
    previousGroupId="${groupId}"
  done
fi
%
%# ------------------------------------------
%# version section
%# ------------------------------------------
%
if [[ -n "${version}" ]]; then
  echo '    echo'
  echo $'    echo -n -e "${__HELP_TITLE_COLOR}VERSION: <% ${version} %>${__RESET_COLOR}"'
  echo "    echo '<% ${version} %>'"
fi
%
%# ------------------------------------------
%# author section
%# ------------------------------------------
%
if [[ -n "${author}" ]]; then
  echo '    echo'
  echo $'    echo -e "${__HELP_TITLE_COLOR}AUTHOR:${__RESET_COLOR}"'
  echo "    echo '<% ${author} %>'"
fi
%
%# ------------------------------------------
%# source file section
%# ------------------------------------------
%
if [[ -n "${sourceFile}" ]]; then
  echo '    echo'
  echo $'    echo -e "${__HELP_TITLE_COLOR}SOURCE FILE:${__RESET_COLOR}"'
  echo "    echo '<% ${sourceFile} %>'"
fi
%
%# ------------------------------------------
%# license section
%# ------------------------------------------
%
if [[ -n "${license}" ]]; then
  echo '    echo'
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
