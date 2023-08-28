#!/usr/bin/env bash

# @description generate command parse function
# @example
#   declare optionGroup=<% Options::generateGroup \
#     --title "Command global options" \
#     --help "The Console component adds some predefined options to all commands:"
#
# @arg $@ args:StringArray list of options/arguments variables references, allowing to link the options/arguments with this command
# @option --title <String|Function> (optional) provides group title
# @option --help <String|Function> provides command description help
# @exitcode 1 if error during option parsing
# @stdout script file generated to group options and to be associated to options using --group option
# @stderr diagnostics information is displayed
# @see Options::generateOption
# @see doc/guides/Options/generateOption.md
Options::generateGroup() {
  # args default values
  local title=""
  local help=""
  local id=""

  setArg() {
    local option="$1"
    local -n argToSet="$2"
    local argCountAfterShift="$3"
    local value="$4"

    if ((argCountAfterShift == 0)); then
      Log::displayError "Options::generateGroup - Option ${option} - a value needs to be specified"
      return 1
    fi
    if [[ -n "${argToSet}" ]]; then
      Log::displayError "Options::generateGroup - only one ${option} option can be provided"
      return 1
    fi
    argToSet="${value}"
  }

  while (($# > 0)); do
    local option="$1"
    case "${option}" in
      --title)
        shift
        setArg "${option}" title "$#" "$1" || return 1
        ;;
      --help)
        shift
        setArg "${option}" help "$#" "$1" || return 1
        ;;
      *)
        Log::displayError "Options::generateGroup - invalid option ${option}"
        return 1
        ;;
    esac
    shift || true
  done
  if [[ -z "${title}" ]]; then
    Log::displayError "Options::generateGroup - option --title is mandatory"
    return 1
  fi

  (
    # generate a function name that will be the output of this script
    local baseGroupFunctionName
    baseGroupFunctionName=$(Options::generateFunctionName "group" "") || return 3
    local groupFunctionName="Options::${baseGroupFunctionName}"

    # generate unique id
    id="${groupFunctionName}"

    # export current values
    export title
    export help
    export id
    export tplDir="${_COMPILE_ROOT_DIR}/src/Options/templates"

    # interpret the template
    local groupFunctionTmpFile
    groupFunctionTmpFile="${TMPDIR}/src/Options/${baseGroupFunctionName}.sh"
    mkdir -p "$(dirname "${groupFunctionTmpFile}")" || return 3
    Options::bashTpl "${tplDir}/group.tpl" | sed -E -e 's/[\t ]+$//' >"${groupFunctionTmpFile}" || return 3
    Log::displayDebug "Generated group function in ${groupFunctionTmpFile}"

    # display the functionOption
    echo "${groupFunctionName}"
  ) || return $?
}
