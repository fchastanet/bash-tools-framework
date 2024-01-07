#!/usr/bin/env bash

# @description Generates a function that allows to manipulate a group of options.
# function generated allows group options using `--group` option when
# using `Options::generateOption`
#
# #### Output on stdout
#
# By default the name of the random generated function name
# is displayed as output of this function.
# By providing the option `--function-name`, the output of this
# function will be the generated function itself with the chosen name.
#
# #### Syntax
#
# ```text
# Usage:  Options2::renderOptionHelp [OPTIONS]
#
# OPTIONS:
#   --title <String|Function>
#   [--help <String|Function>]
#   [--function-name <String>]
# ```
#
# #### Example
#
# ```bash
# declare optionGroup="$(
#   Options2::renderOptionHelp \
#     --title "Command global options" \
#     --help "The Console component adds some predefined options to all commands:"
# )"
# Options::sourceFunction "${optionGroup}"
# "${optionGroup}" help
# ```
#
# @option --title <String|Function> (mandatory) provides group title
# @option --help <String|Function> (optional) provides command description help
# @option --function-name <String> (optional) the name of the function that will be generated
# @exitcode 1 if error during option parsing
# @exitcode 1 if bash-tpl error during template rendering
# @exitcode 2 if file generation error (only if functionName argument empty)
# @stderr diagnostics information is displayed
# @see [generateCommand function](#/doc/guides/Options/generateCommand)
# @see [generateOption function](#/doc/guides/Options/generateOption)
# @see [group function](#/doc/guides/Options/functionGroup)
Options2::renderOptionHelp() {
  if (( $# != 1 )); then
    Log::displayError "Options2::renderOptionHelp - exactly one parameter has to be provided"
    return 1
  fi

  # shellcheck disable=SC2034
  local -n renderOptionHelpInstanceObject=$1
  if ! Options2::validateOptionObject renderOptionHelpInstanceObject; then
    return 2
  fi
  local help title variableType helpValueName min max
  title="$(Object::getProperty renderOptionHelpInstanceObject --property-title)"
  help="$(Object::getProperty renderOptionHelpInstanceObject --property-help)"
  variableType="$(Object::getProperty renderOptionHelpInstanceObject --property-variableType)"
  helpValueName="$(Object::getProperty renderOptionHelpInstanceObject --property-helpValueName)"
  min="$(Object::getProperty renderOptionHelpInstanceObject --property-min)"
  max="$(Object::getProperty renderOptionHelpInstanceObject --property-max)"
  local -a alts
  readarray -t alts < <(Object::getArray renderOptionHelpInstanceObject --array-alt)

  displayHelp() {  
    echo -e "${__HELP_TITLE_COLOR}${title}${__RESET_COLOR}"
    if [[ -z "${help}" ]]; then
      echo "No help available'"
    elif [[ $(type -t "${help}") == "function" ]]; then
      local -a helpArray
      # shellcheck disable=SC2054,SC2206
      mapfile -t helpArray < <(${help})
      Array::wrap2 " " 76 4 "${helpArray[@]}"
    else
      local -a helpArray
      local helpEscaped
      printf -v helpEscaped '%q' "${help}"
      # shellcheck disable=SC2054,SC2206
      helpArray=(${helpEscaped})
      Array::wrap2 " " 76 4 "${helpArray[@]}"
    fi
  }

  helpOpt() {
    local spec=""
    spec+="${__HELP_OPTION_COLOR}"
    spec+="$(Array::join "${__HELP_NORMAL}, ${__HELP_OPTION_COLOR}" "${alts[@]}")"
    if [[ "${variableType}" != "Boolean" ]]; then
      spec+=" <${helpValueName}>"
    fi
    spec+="${__HELP_NORMAL}"
    if ((max == 1)); then
      spec+=' {single}'
      if ((min == 1)); then
        spec+=' (mandatory)'
      fi
    else
      spec+=' {list}'
      if ((min > 0)); then
        spec+=" (at least ${min} times)"
      else
        spec+=' (optional)'
      fi
      if ((max > 0)); then
        spec+=" (at most ${max} times)"
      fi
    fi
    local helpOpt=""
    helpOpt+="${spec//^[[:blank:]]/}"
    echo -e "${helpOpt}"
  }

  displayHelp
  helpOpt
  if [[ -n "${defaultValue}" ]]; then
    echo "Default value: ${defaultValue}"
  fi
  if [[ -n "${authorizedValues}" ]]; then
    echo "Possible values: ${authorizedValues}"
  fi
}
