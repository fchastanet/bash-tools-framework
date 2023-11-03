# function Arg

## Description

`Options::generateArg` generated this function that allows to display help and
parse the configured argument.

## Syntax

```text
Usage: generatedFunctionName COMMAND
```

**Commands:**

_parse_

> parses this configured argument.

_help_

> generates this argument help.

_helpTpl_

> generates this argument help in bash script format (using echo/printf).

_variableName_

> display the configured variable name.

_type_

> display `Argument`.

_variableType_

> display the configured argument type (`Boolean`, `String` or `StringArray`).

_oneLineHelp_

> display argument help one one line (can be useful for debugging purpose).

_min_

> display the configured min option.

_max_

> display the configured max option.

_export_

> exports all the configuration variables of this argument:
>
> - type
> - variableType
> - variableName
> - name
> - min
> - max
> - authorizedValues
> - regexp
> - callback

### Example of a generated function

The call to following function:

```bash
Options::generateArg \
    --variable-name "varName" \
    --min 0 \
    --max 3 \
    --authorized-values "debug|info|warn" \
    --function-name argumentVarName
```

Generates this function:

```bash
argumentVarName() {
  local options_parse_cmd="$1"
  shift || true

  if [[ "${options_parse_cmd}" = "parse" ]]; then
    local -i options_parse_argParsedCountVarName
    ((options_parse_argParsedCountVarName = 0)) || true
    while (($# > 0)); do
      local options_parse_arg="$1"
      case "${options_parse_arg}" in
        -*)
          # ignore options
          ;;
        *)
          # positional arg
          if [[ ! "${options_parse_arg}" =~ debug|info|warn ]]; then
            Log::displayError "Argument varName - value '${options_parse_arg}' is not part of authorized values(debug|info|warn)"
            return 1
          fi
          if ((options_parse_argParsedCountVarName >= 3)); then
            Log::displayError "Argument varName - Maximum number of argument occurrences reached(3)"
            return 1
          fi
          ((++options_parse_argParsedCountVarName))
          varName+=("${options_parse_arg}")
          ;;
      esac
      shift || true
    done
    export varName
  elif [[ "${options_parse_cmd}" = "help" ]]; then
    eval "$(argumentVarName helpTpl)"
  elif [[ "${options_parse_cmd}" = "helpTpl" ]]; then
    # shellcheck disable=SC2016
    echo 'echo -e "  [${__HELP_OPTION_COLOR}varName${__HELP_NORMAL} {list} (at most 3 times)]"'
    echo "echo '    No help available'"
  elif [[ "${options_parse_cmd}" = "variableName" ]]; then
    echo "varName"
  elif [[ "${options_parse_cmd}" = "type" ]]; then
    echo "Argument"
  elif [[ "${options_parse_cmd}" = "variableType" ]]; then
    echo "StringArray"
  elif [[ "${options_parse_cmd}" = "oneLineHelp" ]]; then
    echo "Argument varName min 0 min 3 authorizedValues 'debug|info|warn' regexp ''"
  elif [[ "${options_parse_cmd}" = "min" ]]; then
    echo "0"
  elif [[ "${options_parse_cmd}" = "max" ]]; then
    echo "3"
  elif [[ "${options_parse_cmd}" = "export" ]]; then
    export type="Argument"
    export variableName="varName"
    export variableType="StringArray"
    export name="varName"
    export min="0"
    export max="3"
    export authorizedValues="debug|info|warn"
    export regexp=""
    export callback=""
  else
    Log::displayError "Argument command invalid: '${options_parse_cmd}'"
    return 1
  fi
}
```
