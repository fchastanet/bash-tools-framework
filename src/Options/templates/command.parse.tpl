% for option in "${optionList[@]}"; do
  % "${option}" export
  .INCLUDE "${tplDir}/option.parse.before.tpl"
% done
% for argument in "${argumentList[@]}"; do
  % "${argument}" export
  .INCLUDE "${tplDir}/arg.parse.before.tpl"
% done
local -i options_parse_parsedArgIndex=0
while (($# > 0)); do
  local options_parse_arg="$1"
  case "${options_parse_arg}" in
    % for ((optionIdx=0; optionIdx<${#optionList[@]}; ++optionIdx)); do
      % local option="${optionList[optionIdx]}"
      % echo "        # Option $((optionIdx + 1))/${#optionList[@]}"
      % echo "        # $("${option}" oneLineHelp)"
      % "${option}" export
      .INCLUDE "${tplDir}/option.parse.option.tpl"
    % done
    -*)
      % if [[ "${errorIfUnknownOption}" = "1" ]]; then
        Log::displayError "Invalid option ${options_parse_arg}"
        return 1
      % else
      # ignore
      % fi
      ;;
    *)
      %
      local -i maxParsedArgIndex=0
      local -i minParsedArgIndex=0
      local -i argMin argMax argIdx
      local -i argCount=${#argumentList[@]}
      local argument
      if ((argCount > 0)); then
        echo '          if ((0)); then'
        echo '            # Technical if never reached'
        echo '            :'
        for ((argIdx=0; argIdx<${#argumentList[@]}; ++argIdx)); do
          argument="${argumentList[argIdx]}"
          argMin="$("${argument}" min)"
          argMax="$("${argument}" max)"
          echo "          # Argument $((argIdx + 1))/${argCount}"
          echo "          # $("${argument}" oneLineHelp)"
          ((minParsedArgIndex+=argMax))
          if ((argMax == -1 || argIdx == argCount - 1)); then
          echo "          elif ((options_parse_parsedArgIndex >= ${maxParsedArgIndex})); then"
          else
          echo "          elif ((parsedArgIndex >= ${maxParsedArgIndex} && options_parse_parsedArgIndex < ${minParsedArgIndex})); then"
          fi
          "${argument}" export
      %
        .INCLUDE "${tplDir}/arg.parse.arg.tpl"
      %
          ((maxParsedArgIndex+=argMax))
          ((++argIndex))
        done
        echo '          fi'
      fi
      %
      ((++options_parse_parsedArgIndex))
      ;;
  esac
  shift || true
done
% for option in "${optionList[@]}"; do
  % "${option}" export
  .INCLUDE "${tplDir}/option.parse.after.tpl"
% done
% for argument in "${argumentList[@]}"; do
  % "${argument}" export
  .INCLUDE "${tplDir}/arg.parse.after.tpl"
% done
