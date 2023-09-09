#!/usr/bin/env bash

# @description generate option parse code for String type
# @arg $@ args:StringArray
# @option --default-value <value> (optional) value set by default on the variable (Default: "")
# @option --authorized-values <value> (optional) Indicates the possible value list separated by | character (Default: "" means no check)
# @option --mandatory (optional) makes this option mandatory
# @exitcode 1 if error during option parsing
# @stdout script file generated to parse the arguments following the rules provided
# @stderr diagnostics information is displayed
# @see Options::generateOption
Options::generateOptionString() {
  # args default values
  local min="0"
  local defaultValue=""
  local authorizedValues=""

  while (($# > 0)); do
    case "$1" in
      --default-value)
        shift || true
        defaultValue="$1"
        ;;
      --authorized-values)
        shift || true
        # TODO check if valid regexp
        if [[ "$1" =~ [[:space:]] ]]; then
          Log::displayError "Options::generateOptionString - --authorized-values invalid regexp '$1'"
          return 1
        fi
        authorizedValues="$1"
        ;;
      --mandatory)
        min="1"
        ;;
      -*)
        Log::displayError "Options::generateOptionString - invalid option '$1'"
        return 1
        ;;
      *) ;;
    esac
    shift || true
  done

  echo "export min='${min}'"
  echo "export max='1'"
  echo "export defaultValue='${defaultValue}'"
  echo "export authorizedValues='${authorizedValues}'"
}
