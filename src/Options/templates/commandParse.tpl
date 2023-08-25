% for option in "${optionFunctionList[@]}"; do
  % "${option}" export
  .INCLUDE "${tplDir}/option.parse.before.tpl"
% done
while (($# > 0)); do
  local arg="$1"
  case "${arg}" in
    % for option in "${optionFunctionList[@]}"; do
      % "${option}" export
      .INCLUDE "${tplDir}/option.parse.option.tpl"
    % done
    *)
      % if [[ "${errorIfUnknownOption}" = "1" ]]; then
        Log::displayError "Invalid option ${arg}"
        return 1
      % else
      # ignore
      % fi
      ;;
  esac
  shift || true
done
% for option in "${optionFunctionList[@]}"; do
  % "${option}" export
  .INCLUDE "${tplDir}/option.parse.after.tpl"
% done
