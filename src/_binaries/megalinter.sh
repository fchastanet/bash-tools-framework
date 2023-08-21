#!/usr/bin/env bash
# BIN_FILE=${FRAMEWORK_ROOT_DIR}/bin/megalinter
# VAR_RELATIVE_FRAMEWORK_DIR_TO_CURRENT_DIR=..
# FACADE

IMAGE_NAME=oxsecurity/megalinter-terraform:v7.2.0

HELP="$(
  cat <<EOF
${__HELP_TITLE}Description:${__HELP_NORMAL} run megalinter over this repository
${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME} [--help|-h] prints this help and exits
${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME} [--fix] [--incremental|-i]
    [--log-level <logLevel>] [--filesOnly] [--json] [--image <imageName>] [<files>]

    --fix                     apply linters fixes automatically
    --incremental|-i          run megalinter only on files that are git staged
    --log-level <logLevel>    set megalinter log level
      <logLevel> can be one of these values: debug, info, warning, error
    --filesOnly               skip linters that run in project mode
    --json                    generate megalinter report in json format
    --image <imageName>       specify docker megalinter image name to use (default: ${IMAGE_NAME})
    <files> optionally you can provide a list of files to run megalinter on

.INCLUDE "$(dynamicTemplateDir _includes/author.tpl)"
EOF
)"

# read command parameters
# $@ is all command line parameters passed to the script.
# -o is for short options like -h
# -l is for long options with double dash like --help
# the comma separates different long options
options=$(getopt -l help,log-level:,incremental,fix,json,filesOnly,image: -o hi: -- "$@" 2>/dev/null) || {
  Args::showHelp "${HELP}"
  Log::fatal "invalid options specified"
}

declare -a megalinterOptions=(
  -e CLEAR_REPORT_FOLDER=true
)
eval set -- "${options}"
while true; do
  case $1 in
    -h | --help)
      Args::showHelp "${HELP}"
      exit 0
      ;;
    --log-level)
      shift || true
      LOG_LEVEL="$1"
      ;;
    --json)
      megalinterOptions+=(-e JSON_REPORTER=true)
      ;;
    --filesOnly)
      megalinterOptions+=(-e SKIP_CLI_LINT_MODES=project)
      ;;
    --fix)
      megalinterOptions+=(-e APPLY_FIXES=all)
      ;;
    --incremental | -i)
      INCREMENTAL=1
      ;;
    --image)
      shift || true
      IMAGE_NAME=$1
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

if [[ -n "${LOG_LEVEL+unset}" ]]; then
  megalinterOptions+=(
    -e "LOG_LEVEL=${LOG_LEVEL}"
  )
fi

if (($# > 0)); then
  if [[ "${INCREMENTAL}" = "1" ]]; then
    Log::fatal "you cannot provide a list of files and the --incremental option"
  fi
  megalinterOptions+=(-e MEGALINTER_FILES_TO_LINT="$(Array::join "," "$@")")
fi

if [[ "${INCREMENTAL}" = "1" ]]; then
  IFS=$'\n' read -r -d '' -a updatedFiles < <(git --no-pager diff --name-only --cached || true) || true
  megalinterOptions+=(-e MEGALINTER_FILES_TO_LINT="$(Array::join "," "${updatedFiles[@]}")")
fi

if [[ -z "$(docker image ls -q "${IMAGE_NAME}")" ]]; then
  docker pull "${IMAGE_NAME}"
fi

if tty -s; then
  megalinterOptions+=("-it")
fi

if [[ -d "vendor/bash-tools-framework" ]]; then
  megalinterOptions+=(
    -v "$(cd vendor/bash-tools-framework && pwd -P):/tmp/lint/vendor/bash-tools-framework"
  )
fi

declare cmd=(
  docker run --rm --name=megalinter
  -e HOST_USER_ID="$(id -u)"
  -e HOST_GROUP_ID="$(id -g)"
  "${megalinterOptions[@]}"
  -v /var/run/docker.sock:/var/run/docker.sock:rw
  -v "${FRAMEWORK_ROOT_DIR}":/tmp/lint:rw
  oxsecurity/megalinter-terraform:v6.16.0
)
Log::displayInfo "Running ${cmd[*]}"
"${cmd[@]}"
