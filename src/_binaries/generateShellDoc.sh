#!/usr/bin/env bash
# BIN_FILE=${ROOT_DIR}/bin/generateShellDoc
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..

.INCLUDE "${TEMPLATE_DIR}/_includes/_header.tpl"

# Usage info
showHelp() {
  cat <<EOF
${__HELP_TITLE}Description:${__HELP_NORMAL} find all .sh files and generate shDoc
in markdown format in the specified target directory

${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME} [-h|--help] prints this help and exits
${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME} {fromDir} {docDir} {indexFile}

  --help,-h : prints this help and exits
  fromDir   : directory from which sh files will be searched
  docDir    : target doc directory
  indexFile : the markdown index file
EOF
}

# read command parameters
# $@ is all command line parameters passed to the script.
# -o is for short options like -h
# -l is for long options with double dash like --help
# the comma separates different long options
options=$(getopt -l help -o h -- "$@" 2>/dev/null) || {
  showHelp
  Log::fatal "invalid options specified"
}

eval set -- "${options}"
while true; do
  case $1 in
    -h | --help)
      showHelp
      exit 0
      ;;
    --)
      shift || true
      break
      ;;
    *)
      showHelp
      Log::fatal "invalid argument $1"
      ;;
  esac
  shift || true
done

if (($# != 3)); then
  Log::fatal "yous should provide exactly 3 parameters"
fi

declare fromDir="$1"
declare docDir="$2"
declare indexFile="$3"

fromDir="$(realpath "${fromDir}")"
docDir="$(realpath "${docDir}")"
indexFile="$(realpath "${indexFile}")"

if [[ ! -d "${fromDir}" ]]; then
  Log::fatal "From directory '${fromDir}' does not exists"
fi
if [[ ! -r "${fromDir}" ]]; then
  Log::fatal "From directory '${fromDir}' is not readable"
fi

mkdir -p "${docDir}" || true
if [[ ! -w "${docDir}" ]]; then
  Log::fatal "From directory '${fromDir}' is not writeable"
fi

if ! Assert::fileWritable "${indexFile}"; then
  Log::fatal "File ${indexFile} is not writeable"
fi

# reset index file
if [[ -f "${indexFile}" ]]; then
  echo >"${indexFile}"
fi

ShellDoc::generateShellDocsFromDir \
  "${fromDir}" \
  "${docDir}" \
  "${indexFile}"
