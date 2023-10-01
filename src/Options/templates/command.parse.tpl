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
  local argOptDefaultBehavior=0
  case "${options_parse_arg}" in
    % for ((optionIdx=0; optionIdx<${#optionList[@]}; ++optionIdx)); do
      % local option="${optionList[optionIdx]}"
      % echo "        # Option $((optionIdx + 1))/${#optionList[@]}"
      % echo "        # $("${option}" oneLineHelp)"
      % "${option}" export
      .INCLUDE "${tplDir}/option.parse.option.tpl"
    % done
    -*)
      % for everyOptionCallback in "${everyOptionCallbacks[@]}"; do
        # shellcheck disable=SC2317
        <% ${everyOptionCallback} %> "" "${options_parse_arg}" || argOptDefaultBehavior=$?
      % done
      % if (( ${#unknownOptionCallbacks[@]} == 0 )); then
        if [[ "${argOptDefaultBehavior}" = "0" ]]; then
          Log::displayError "Command ${SCRIPT_NAME} - Invalid option ${options_parse_arg}"
          return 1
        fi
      % else
        % for unknownOptionCallback in "${unknownOptionCallbacks[@]}"; do
          <% ${unknownOptionCallback} %> "${options_parse_arg}"
        % done
      % fi
      ;;
    *)
      %
      local -i maxParsedArgIndex=0
      local -i minParsedArgIndex=0
      local -i argMin argMax argIdx
      local -i argCount=${#argumentList[@]}
      local -i incrementArg=1
      local argument
      if ((argCount > 0)); then
        echo '          if ((0)); then'
        echo '            # Technical if - never reached'
        echo '            :'
        for ((argIdx=0; argIdx<${#argumentList[@]}; ++argIdx)); do
          argument="${argumentList[argIdx]}"
          argMin="$("${argument}" min)"
          argMax="$("${argument}" max)"
          echo "          # Argument $((argIdx + 1))/${argCount}"
          echo "          # $("${argument}" oneLineHelp)"
          ((minParsedArgIndex+=argMax))
          if ((argMax == -1)); then
          echo "          elif ((options_parse_parsedArgIndex >= ${maxParsedArgIndex})); then"
          #elif ((argIdx != argCount - 1)); then
          else
          echo "          elif ((options_parse_parsedArgIndex >= ${maxParsedArgIndex} && options_parse_parsedArgIndex < ${minParsedArgIndex})); then"
          fi
          "${argument}" export
      %
        .INCLUDE "${tplDir}/arg.parse.arg.tpl"
      %
          for everyArgumentCallback in "${everyArgumentCallbacks[@]}"; do
            echo "            ${everyArgumentCallback} '${variableName}'" '"${options_parse_arg}" || true'
          done
          ((maxParsedArgIndex+=argMax))
          ((++argIndex))
        done
        # else too much args
        echo '          else'
        for everyArgumentCallback in "${everyArgumentCallbacks[@]}"; do
          echo "            ${everyArgumentCallback} ''" '"${options_parse_arg}" || argOptDefaultBehavior=$?'
        done
        if (( ${#unknownArgumentCallbacks[@]} > 0 )); then
          for unknownArgumentCallback in "${unknownArgumentCallbacks[@]}"; do
            echo "            ${unknownArgumentCallback}" '"${options_parse_arg}"'
          done
        else
          echo '            if [[ "${argOptDefaultBehavior}" = "0" ]]; then'
          # too much args and no unknownArgumentCallbacks configured
          echo '              Log::displayError "Command ${SCRIPT_NAME} - Argument - too much arguments provided: $*"'
          echo "              return 1"
          echo "            fi"
        fi
        echo '          fi'
      elif (( ${#unknownArgumentCallbacks[@]} > 0 )); then
        # else no arg configured, call unknownArgumentCallback
        for unknownArgumentCallback in "${unknownArgumentCallbacks[@]}"; do
          echo "          ${unknownArgumentCallback}" ' "${options_parse_arg}"'
        done
        for everyArgumentCallback in "${everyArgumentCallbacks[@]}"; do
          echo "          ${everyArgumentCallback} '' '${options_parse_arg}' || true"
        done
      else
        for everyArgumentCallback in "${everyArgumentCallbacks[@]}"; do
          echo "          ${everyArgumentCallback} '' '${options_parse_arg}' || argOptDefaultBehavior=\$?"
        done
        # no arg and no unknownArgumentCallbacks configured
        echo '          if [[ "${argOptDefaultBehavior}" = "0" ]]; then'
        echo '            Log::displayError "Command ${SCRIPT_NAME} - Argument - too much arguments provided"'
        echo "            return 1"
        echo '          fi'
        incrementArg=0 # to avoid parse error after return
      fi
      if ((incrementArg==1)); then
      echo "          ((++options_parse_parsedArgIndex))"
      fi
      %
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
% for commandCallback in "${commandCallbacks[@]}"; do
  <% ${commandCallback} %>
% done
