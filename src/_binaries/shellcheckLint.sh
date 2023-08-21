#!/usr/bin/env bash
# BIN_FILE=${FRAMEWORK_ROOT_DIR}/bin/shellcheckLint
# VAR_RELATIVE_FRAMEWORK_DIR_TO_CURRENT_DIR=..
# FACADE

if [[ -z "${DEFAULT_ARGS+unset}" ]]; then
  DEFAULT_ARGS=(-f tty)
fi
MIN_SHELLCHECK_VERSION="0.9.0"

# check if command in PATH is already the minimal version needed
if ! Version::checkMinimal "${FRAMEWORK_VENDOR_BIN_DIR}/shellcheck" "--version" "${MIN_SHELLCHECK_VERSION}" >/dev/null 2>&1; then
  install() {
    local file="$1"
    local targetFile="$2"
    local version="$3"
    local tempDir
    tempDir="$(mktemp -d -p "${TMPDIR:-/tmp}" -t bash-framework-shellcheck-$$-XXXXXX)"
    (
      cd "${tempDir}" || exit 1
      tar -xJvf "${file}"
      mv "shellcheck-v${version}/shellcheck" "${targetFile}"
      chmod +x "${targetFile}"
    )
  }
  Github::upgradeRelease \
    "${FRAMEWORK_VENDOR_BIN_DIR}/shellcheck" \
    "https://github.com/koalaman/shellcheck/releases/download/v@latestVersion@/shellcheck-v@latestVersion@.linux.x86_64.tar.xz" \
    "--version" \
    Version::getCommandVersionFromPlainText \
    install
fi

HELP="$(
  cat <<EOF
${__HELP_TITLE}Synopsis:${__HELP_NORMAL} shellcheck wrapper

${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME} [--help] prints this help and exits.
${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME} [--staged] <shellcheck options>

  [--staged] lint only staged git files which are beginning with a bash shebang.

${__HELP_TITLE}Description:${__HELP_NORMAL}
shellcheck wrapper that will
- install new shellcheck version(${MIN_SHELLCHECK_VERSION}) automatically
- by default, lint all git files of this project which are beginning with a bash shebang
  except if the option --staged is passed
- use the default options '${DEFAULT_ARGS[*]}' if no parameter specified

${__HELP_TITLE}Special configuration .shellcheckrc:${__HELP_NORMAL}
use the following line in your .shellcheckrc file to exclude
some files from being checked (use grep -E syntax)
exclude=^bin/bash-tpl$

.INCLUDE "$(dynamicTemplateDir _includes/author.tpl)"

${__HELP_TITLE}Shellcheck help:${__HELP_NORMAL}
EOF
)"

declare -a savedOptions=("$@")

# read command parameters
# $@ is all command line parameters passed to the script.
# -o is for short options like -h
# -l is for long options with double dash like --help
# the comma separates different long options
options=$(getopt -n "$0" -l help,staged -o h -- "${BASH_FRAMEWORK_ARGV[@]}" 2>/dev/null || true)
ONLY_STAGED=0
eval set -- "${options}"
while true; do
  case $1 in
    -h | --help)
      Args::showHelp "${HELP}"
      "${FRAMEWORK_VENDOR_BIN_DIR}/shellcheck" --help
      exit 0
      ;;
    --staged)
      ONLY_STAGED=1
      ;;
    --)
      break
      ;;
    *) ;;

  esac
  shift || true
done

# shell check options without this command option
for i in "${!savedOptions[@]}"; do
  if [[ "${savedOptions[i]}" = "--staged" ]]; then
    unset 'savedOptions[i]'
  fi
done

if ((${#savedOptions[@]} == 0)); then
  set -- "${DEFAULT_ARGS[@]}"
else
  set -- "${savedOptions[@]}"
fi

(
  exclude="$(sed -n -E 's/^exclude=(.+)$/\1/p' "${FRAMEWORK_ROOT_DIR}/.shellcheckrc" 2>/dev/null || true)"
  if [[ -z "${exclude}" ]]; then
    exclude='^$'
  fi
  export -f File::detectBashFile
  export -f Assert::bashFile

  (
    if [[ "${ONLY_STAGED}" = "1" ]]; then
      git --no-pager diff --name-only --cached --diff-filter=udbx
    else
      git ls-files --exclude-standard -c -o -m
    fi
  ) |
    (grep -E -v "${exclude}" || true) |
    LC_ALL=C.UTF-8 xargs -r -L 1 -n 1 -I@ bash -c "File::detectBashFile '@'"
)
