#!/usr/bin/env bash
# BIN_FILE=${ROOT_DIR}/bin/plantuml

.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/_header.tpl"

HELP="$(
  cat <<EOF
${__HELP_TITLE}Synopsis:${__HELP_NORMAL} Generates plantuml diagrams from puml files

${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME} [--help] prints this help and exits.
${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME} [-f svg|png]

${__HELP_TITLE}Description:${__HELP_NORMAL}
Generates plantuml diagrams from puml files in formats provided

.INCLUDE "$(dynamicTemplateDir _includes/author.tpl)"
EOF
)"

declare args
args="$(getopt -l help,format: -o hf: -- "$@" 2>/dev/null)" || true
eval set -- "${args}"
declare FORMATS=()

while true; do
  case $1 in
    -h | --help)
      echo -e "${HELP}"
      exit 0
      ;;
    -f | --format)
      shift || true
      FORMATS+=("$1")
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

detectChangedAddedFiles() {
  git ls-files --exclude-standard --modified --others
}

changedFilesBefore=$(detectChangedAddedFiles)
for format in "${FORMATS[@]}"; do
  docker run --rm -v "$(pwd -P)":/app/project plantuml/plantuml \
    -u "$(id -u):$(id -g)" -t"${format}" -failfast \
    -o/app/project/images "/app/project/src/**/*.puml"
done
changedFilesAfter=$(detectChangedAddedFiles)

diff <(echo "${changedFilesBefore}") <(echo "${changedFilesAfter}") >&2 || {
  Log::fatal "files have been added"
}
