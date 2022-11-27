#!/bin/bash
PROFILE=
SKIP_INSTALL=0
SKIP_CONFIGURE=0
SKIP_TEST=0
PREPARE_EXPORT=0
SKIP_DEPENDENCIES=0

if [[ "$#" = "0" ]]; then
  showHelp
  Log::fatal "You have to specify a profile using -p option or specify a software to install"
fi

# read command parameters
# $@ is all command line parameters passed to the script.
# -o is for short options like -h
# -l is for long options with double dash like --help
# the comma separates different long options
options=$(getopt -l "${LONG_OPTIONS}" -o "${SHORT_OPTIONS}" -- "$@" 2>/dev/null) || {
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
    -p | --profile)
      shift || true
      PROFILE="$1"
      if [[ ! -f "${ROOT_DIR}/profile.${PROFILE}.sh" ]]; then
        Log::fatal "Profile profile.${PROFILE}.sh doesn't exist"
      fi
      ;;
    --prepare-export)
      PREPARE_EXPORT=1
      ;;
    --skip-installation | --skip-install)
      SKIP_INSTALL=1
      ;;
    --skip-config | --skip-configure | --skip-configuration)
      SKIP_CONFIGURE=1
      ;;
    --skip-test | --skip-tests)
      SKIP_TEST=1
      ;;
    --skip-dependencies)
      SKIP_DEPENDENCIES=1
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

if (($# > 0)); then
  if [[ -n "${PROFILE}" ]]; then
    Log::fatal "You cannot combine profile and softwares"
  fi
  # check if each Softwares exists
  for software in "$@"; do
    if ! ls "${ROOT_DIR}/scripts/${software}" &>/dev/null; then
      Log::fatal "Software scripts/${software} configuration does not exists"
    fi
  done
  CONFIG_LIST=("$@")
fi
export CONFIG_LIST
export PROFILE
export SKIP_INSTALL
export SKIP_CONFIGURE
export SKIP_TEST
export PREPARE_EXPORT
export SKIP_DEPENDENCIES
