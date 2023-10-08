#!/usr/bin/env bash

# @description generate option parse code for String type
# @arg $1 mandatory:int 1 if option mandatory
# @arg $@ args:StringArray
# @option --min <value> (optional) minimum number of options to provide (Defaults to 0 or 1 if mandatory).
# @option --max <value> (optional) maximum number of options to provide (Default "" means no limit)
# @option --authorized-values <value> (optional) Indicates the possible value list separated by | character (Default: "" means no check)
# @option --help-value-name <valueName> (optional) Indicates the name of value of the option to display in help (Default: "String")
# @exitcode 1 if error during option parsing
# @stdout script file generated to parse the arguments following the rules provided
# @stderr diagnostics information is displayed
# @see Options::generateOption
Options::generateOptionStringArray() {
  # args default values
  local min="0"
  local max="-1"
  local authorizedValues=""
  local helpValueName="String"

  while (($# > 0)); do
    case "$1" in
      --authorized-values)
        shift || true
        # TODO check if valid regexp
        if [[ "$1" =~ [[:space:]] ]]; then
          Log::displayError "Options::generateOptionString - --authorized-values invalid regexp '$1'"
          return 1
        fi
        authorizedValues="$1"
        ;;
      --min)
        shift || true
        if [[ ! "$1" =~ ^[0-9]+$ ]]; then
          Log::displayError "Options::generateOptionStringArray - --min value should be an integer greater than or equal to 0"
          return 1
        fi
        min="$1"
        ;;
      --max)
        shift || true
        if [[ -n "$1" && ! "$1" =~ ^([1-9][0-9]*|-1)$ ]]; then
          Log::displayError "Options::generateOptionStringArray - --max value should be an integer greater than 0 or -1"
          return 1
        fi
        max="$1"
        ;;
      --help-value-name)
        shift || true
        # TODO check if valid regexp
        if [[ "$1" =~ [[:space:]] ]]; then
          Log::displayError "Options::generateOptionString - --help-value-name invalid regexp '$1'"
          return 1
        fi
        helpValueName="$1"
        ;;
      --mandatory)
        min="1"
        ;;
      -*)
        Log::displayError "Options::generateOption - invalid option '$1'"
        return 1
        ;;
      *) ;;
    esac
    shift || true
  done

  if ((max != -1 && min > max)); then
    Log::displayError "Options::generateOptionStringArray - --max value should be greater than --min value"
    return 1
  fi

  echo "export min='${min}'"
  echo "export max='${max}'"
  echo "export authorizedValues='${authorizedValues}'"
  echo "export helpValueName='${helpValueName}'"
}
