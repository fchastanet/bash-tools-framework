#!/usr/bin/env bash
# BIN_FILE=${FRAMEWORK_ROOT_DIR}/bin/definitionLint
# VAR_RELATIVE_FRAMEWORK_DIR_TO_CURRENT_DIR=..
# VAR_DEPRECATED_LOAD=1
# FACADE

FORMAT="plain"
HELP="$(
  cat <<EOF
${__HELP_TITLE}Synopsis:${__HELP_NORMAL} lint definitions files

${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME} [-h|--help] displays this help and exits
${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME} [-f|--format <checkstyle,plain>] <folder>

${__HELP_TITLE}Description:${__HELP_NORMAL}
Lint files of the given directory
- check that all mandatory methods are existing
  installScripts_<fileName>_helpDescription
  installScripts_<fileName>_helpVariables
  installScripts_<fileName>_listVariables
  installScripts_<fileName>_defaultVariables
  installScripts_<fileName>_checkVariables
  installScripts_<fileName>_fortunes
  installScripts_<fileName>_dependencies
  installScripts_<fileName>_breakOnConfigFailure
  installScripts_<fileName>_breakOnTestFailure
  installScripts_<fileName>_install
  installScripts_<fileName>_configure
  installScripts_<fileName>_test
- check if other definitions files functions are defined by currently
  linted definition file it would mean that another file has defined
  the same methods
- check if each dependency exists

${__HELP_TITLE}Options:${__HELP_NORMAL}
  -f|--format <checkstyle,plain>  define output format of this command
    (default: plain)

.INCLUDE "$(dynamicTemplateDir _includes/author.tpl)"
EOF
)"

declare args
args="$(getopt -l help,format: -o hf: -- "$@" 2>/dev/null)" || true
eval set -- "${args}"

while true; do
  case $1 in
    -h | --help)
      echo -e "${HELP}"
      exit 0
      ;;
    -f | --format)
      shift || true
      if ! Array::contains "$1" "checkstyle" "plain"; then
        Log::fatal "format option invalid"
      fi
      FORMAT="$1"
      ;;
    --)
      shift || true
      break
      ;;
    *)
      # ignore
      ;;
  esac
  shift || true
done

if (($# != 1)); then
  Log::fatal "This command needs exactly one parameter"
fi

scriptsDir="$1"

Profiles::lintDefinitions "${scriptsDir}" "${FORMAT}"
