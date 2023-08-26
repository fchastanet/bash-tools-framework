#!/usr/bin/env bash

# @description generate command parse function
# @example
#   declare commandForm=<% Options::generateCommand \
#     --help "Command help" \
#     --version "version 1.0" \
#     --author "author is me" \
#     --command-name "myCommand" \
#     --license "MIT License" \
#     --copyright "Copyright" \
#     --help-template "path/to/template.tpl"
#
# @arg $@ args:StringArray list of options variables references, allowing to link the options with this command
# @option --help <String|Function> provides command description help
# @option --version <String|Function> (optional) provides version section help. Section not generated if not provided.
# @option --author <String|Function> (optional) provides author section help. Section not generated if not provided.
# @option --command-name <String|Function> (optional) provides the command name. (Default: name of current command file without path)
# @option --license <String|Function> (optional) provides License section help Section not generated if not provided.
# @option --copyright <String|Function> (optional) provides copyright section help Section not generated if not provided.
# @option --help-template <String|Function> (optional) if you want to override the default template used to generate the help
# @option --no-error-if-unknown-option (optional) options parser doesn't display any error message if an option provided does not match any specified options.
# @exitcode 1 if error during option parsing
# @exitcode 2 if error during option type parsing
# @exitcode 3 if error during template rendering
# @stdout script file generated to parse the arguments following the rules provided
# @stderr diagnostics information is displayed
# @see Options::generateOption
# @see doc/guides/Options/generateCommand.md
Options::generateCommand() {
  # args default values
  local help=""
  local version=""
  local author=""
  local commandName=""
  local license=""
  local copyright=""
  local helpTemplate=""
  local errorIfUnknownOption="1"
  local -a optionFunctionList=()

  setArg() {
    local option="$1"
    local -n argToSet="$2"
    local argCountAfterShift="$3"
    local value="$4"

    if ((argCountAfterShift == 0)); then
      Log::displayError "Options::generateCommand - Option ${option} - a value needs to be specified"
      return 1
    fi
    if [[ -n "${argToSet}" ]]; then
      Log::displayError "Options::generateCommand - only one ${option} option can be provided"
      return 1
    fi
    argToSet="${value}"
  }

  while (($# > 0)); do
    local option="$1"
    case "${option}" in
      --help)
        shift
        setArg "${option}" help "$#" "$1" || return 1
        ;;
      --version)
        shift
        setArg "${option}" version "$#" "$1" || return 1
        ;;
      --author)
        shift
        setArg "${option}" author "$#" "$1" || return 1
        ;;
      --command-name)
        shift
        setArg "${option}" commandName "$#" "$1" || return 1
        ;;
      --license)
        shift
        setArg "${option}" license "$#" "$1" || return 1
        ;;
      --copyright)
        shift
        setArg "${option}" copyright "$#" "$1" || return 1
        ;;
      --help-template)
        shift
        setArg "${option}" helpTemplate "$#" "$1" || return 1
        # TODO check if valid template file
        ;;
      --no-error-if-unknown-option)
        errorIfUnknownOption="0"
        ;;
      *)
        if [[ "${option}" =~ ^-- ]]; then
          Log::displayError "Options::generateCommand - invalid option provided '$1'"
          return 1
        fi
        if [[ "$(type -t "$1")" != "function" ]]; then
          Log::displayError "Options::generateCommand - only function type are accepted as positional argument - invalid '$1'"
          return 1
        fi
        optionFunctionList+=("$1")
        ;;
    esac
    shift || true
  done
  if [[ -z "${helpTemplate}" ]]; then
    helpTemplate="${_COMPILE_ROOT_DIR}/src/Options/templates/commandHelp.tpl"
  fi
  if ((${#optionFunctionList} == 0)); then
    Log::displayError "Options::generateCommand - at least one option must be provided as positional argument"
    return 1
  fi
  if [[ -z "${commandName}" ]]; then
    # shellcheck disable=SC2016
    commandName='${SCRIPT_NAME}'
  fi

  (
    # generate a function name that will be the output of this script
    local baseCommandFunctionName
    baseCommandFunctionName=$(Options::generateFunctionName "command" "") || return 3
    local commandFunctionName="Options::${baseCommandFunctionName}"

    # export current values
    export help
    export version
    export author
    export commandName
    export license
    export copyright
    export helpTemplate
    export optionFunctionList
    export commandFunctionName
    export errorIfUnknownOption
    export tplDir="${_COMPILE_ROOT_DIR}/src/Options/templates"

    # interpret the template
    local commandFunctionTmpFile
    commandFunctionTmpFile="${TMPDIR}/src/Options/${baseCommandFunctionName}.sh"
    mkdir -p "$(dirname "${commandFunctionTmpFile}")" || return 3
    Options::bashTpl "${tplDir}/command.tpl" | sed -E -e 's/[\t ]+$//' >"${commandFunctionTmpFile}" || return 3
    Log::displayDebug "Generated command function in ${commandFunctionTmpFile}"

    # display the functionOption
    echo "${commandFunctionName}"
  ) || return $?
}
