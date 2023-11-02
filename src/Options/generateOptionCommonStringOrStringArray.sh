#!/usr/bin/env bash

# @description generate option parse code for String type
# @arg $1 type:String the type of variable to manage (used for logs)
# @arg $@ args:StringArray
# @option --authorized-values <value> (optional) Indicates the possible value list separated by | character (Default: "" means no check)
# @option --help-value-name <valueName> (optional) Indicates the name of value of the option to display in help (Default: "String")
# @exitcode 1 if error during option parsing
# @stdout script file generated to parse the arguments following the rules provided
# @stderr diagnostics information is displayed
# @see Options::generateOption
Options::generateOptionCommonStringOrStringArray() {
  local type="$1"
  shift || true
  # args default values
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
      --help-value-name)
        shift || true
        # TODO check if valid regexp
        if [[ "$1" =~ [[:space:]] ]]; then
          Log::displayError "Options::generateOptionString - --help-value-name invalid regexp '$1'"
          return 1
        fi
        helpValueName="$1"
        ;;
      *) ;;
    esac
    shift || true
  done

  echo "export authorizedValues='${authorizedValues}'"
  echo "export helpValueName='${helpValueName}'"
}
