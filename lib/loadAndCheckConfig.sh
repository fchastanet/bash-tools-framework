#!/bin/bash

if [[ -n "${__LIB_LOAD_AND_CHECK_CONFIG_FILE__+unset}" ]]; then
  # file already included
  return 0
fi
__LIB_LOAD_AND_CHECK_CONFIG_FILE__="$0"
LIB_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)"
ROOT_DIR="$(cd "${LIB_DIR}/.." && pwd -P)"

# load ~/.bash-tools/.env and wslDir/.env file
# and check validity of the variables
loadAndCheckConfig() {
  local ROOT_DIR="$1"
  LIB_DIR="$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")" && pwd)"

  if [[ ! -f "${ROOT_DIR}/.env" ]]; then
    Log::displayError "Please run the following to initialize .env"
    (echo >&2 "cp ${ROOT_DIR}/.env.template ${ROOT_DIR}/.env")
    exit 1
  fi

  # shellcheck source=/.env.template
  source "${ROOT_DIR}/.env"

  if ! getent passwd "${USERNAME}" 2>/dev/null >/dev/null; then
    Log::fatal "USERNAME - user '${USERNAME}' does not exist (check ${ROOT_DIR}/.env file)"
  fi
  # deduce user home and group
  HOME="$(getent passwd "${USERNAME}" | cut -d: -f6)"
  USERID="$(getent passwd "${USERNAME}" | cut -d: -f3)"
  USERGROUPID="$(getent passwd "${USERNAME}" | cut -d: -f4)"
  USERGROUP="$(getent group "${USERGROUPID}" | cut -d: -f1)"
  HOSTIP="$(/sbin/ip route | awk '/default/ { print $3 }')"

  WINDOWS_PROFILE_DIR=""
  if command -v wslpath &>/dev/null; then
    WINDOWS_PROFILE_DIR="$(Wsl::cachedWslpathFromWslVar USERPROFILE)"
  fi

  if [[ -z "${USERGROUP}" || -z "${HOME}" ]]; then
    Log::fatal "USERNAME - unable to deduce USERGROUP, HOME from USERNAME in ${ROOT_DIR}/.env file"
  fi
  if Functions::isWsl; then
    # shellcheck disable=SC1003
    BASE_MNT_C="$(mount | grep 'path=C:\\' | awk -F ' ' '{print $3}')"
    if [[ -z "${LOCAL_APP_DATA}" ]]; then
      LOCAL_APP_DATA="$(Wsl::cachedWslpathFromWslVar LOCALAPPDATA | tr -d '\n\r')"
    fi
    WINDOW_PATH="$(Wsl::cachedWslvar PATH)"
    WINDOW_PATH="${WINDOW_PATH//;/:}"
    WINDOW_PATH="${WINDOW_PATH//\\//}"
    WINDOW_PATH="${WINDOW_PATH//C:/${BASE_MNT_C}}"
  fi

  # reinterpret .env file after HOME/USERGROUP resolution
  # shellcheck source=/.env.template
  source "${ROOT_DIR}/.env"

  # make variables available for configure and install scripts
  export USERID
  export USERGROUP
  export USERGROUPID
  export USERNAME
  export POWERSHELL_BIN
  export WILEY_USER_MAIL
  export DEV_USER_NAME
  export LDAP_LOGIN
  export CONF_DIR="${CONF_DIR:-${ROOT_DIR}/conf}"
  export ROOT_DIR
  export LOGS_DIR="${LOGS_DIR:-${ROOT_DIR}/logs}"
  export PROJECTS_DIR="${PROJECTS_DIR:-${HOME}/projects}"
  export BACKUP_DIR="${BACKUP_DIR:-${ROOT_DIR}/backup}"
  export SCRIPTS_DIR="${SCRIPTS_DIR:-${ROOT_DIR}/scripts}"
  export IPCONFIG
  export HOSTIP
  export LIB_DIR
  export LOCAL_APP_DATA
  export WINDOWS_PROFILE_DIR
  export WINDOW_PATH
  export BASE_MNT_C

  # DEV_USER_NAME
  if [[ -z ${DEV_USER_NAME+unset} || -z "${DEV_USER_NAME}" ]]; then
    Log::fatal "DEV_USER_NAME - please provide a value in ${ROOT_DIR}/.env file"
  fi
  if ! Functions::validateFirstNameLastName "${DEV_USER_NAME}"; then
    Log::fatal "DEV_USER_NAME - invalid format, expected : firstName lastName in ${ROOT_DIR}/.env file"
  fi

  # WILEY_USER_MAIL
  if [[ -z ${WILEY_USER_MAIL+unset} || -z "${WILEY_USER_MAIL}" ]]; then
    Log::fatal "WILEY_USER_MAIL: please provide a value in ${ROOT_DIR}/.env file"
  fi
  if ! Functions::validateEmailAddress "${WILEY_USER_MAIL}" "wiley.com"; then
    Log::fatal "WILEY_USER_MAIL: invalid email address in ${ROOT_DIR}/.env file"
  fi

  # LDAP_LOGIN
  if [[ -z ${LDAP_LOGIN+unset} || -z "${LDAP_LOGIN}" ]]; then
    Log::fatal "LDAP_LOGIN: invalid format, expected : firstNameLastName in ${ROOT_DIR}/.env file"
  fi
  if ! Functions::validateLdapLogin "${LDAP_LOGIN}"; then
    Log::fatal "LDAP_LOGIN: invalid ldap login in ${ROOT_DIR}/.env file"
  fi

  # PROJECTS_DIR
  if [[ -z ${PROJECTS_DIR+unset} || -z "${PROJECTS_DIR}" ]]; then
    Log::fatal "invalid format, expected path in ${ROOT_DIR}/.env file"
  fi
  if [[ ! -d "${PROJECTS_DIR}" ]]; then
    if ! mkdir -p "${PROJECTS_DIR}"; then
      Log::fatal "PROJECTS_DIR - impossible to create the directory '${PROJECTS_DIR}' in ${ROOT_DIR}/.env file"
    fi
  fi

  # CONF_DIR
  if [[ -z ${CONF_DIR+unset} || -z "${CONF_DIR}" ]]; then
    Log::displayError "invalid format, expected : firstName lastName in ${ROOT_DIR}/.env file"
  fi

  if [[ ! -d "${CONF_DIR}" ]]; then
    Log::displayError "CONF_DIR - directory does not exist '${CONF_DIR}' in ${ROOT_DIR}/.env file"
  fi

  if [[ ! -r "${CONF_DIR}" ]]; then
    Log::displayError "CONF_DIR - directory '${CONF_DIR}' is not accessible"
  fi

  # BACKUP_DIR
  if [[ ! -d "${BACKUP_DIR}" ]]; then
    mkdir -p "${BACKUP_DIR}" || Log::fatal "BACKUP_DIR - backup dir ${BACKUP_DIR} cannot be created"
  fi
  if [[ ! -w "${BACKUP_DIR}" ]]; then
    Log::fatal "BACKUP_DIR - backup dir ${BACKUP_DIR} is not writable"
  fi

  # set sudoer without password temporarily
  if [[ ! -f "/etc/sudoers.d/${USERNAME}-no-password" ]]; then
    # (
    #     echo "Defaults    passwd_timeout=0"
    #     # number of seconds 1440s=24h
    #     echo "Defaults    timestamp_type=tty,timestamp_timeout=1440"
    # ) > /etc/sudoers.d/defaults
    # chmod 440 /etc/sudoers.d/defaults

    # update /etc/sudoers to set unlimited sudo after ask password
    Log::displayInfo "Set sudo without password"
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" | sudo tee "/etc/sudoers.d/${USERNAME}-no-password"
    sudo chmod 0440 "/etc/sudoers.d/${USERNAME}-no-password"
    echo "this file indicates that sudo has been configured to execute without password" |
      sudo tee "${HOME}/.cron_activated" >/dev/null

    sudo visudo -c -s || {
      Log::fatal "Please check syntax of /etc/sudoers.d/${USERNAME}-no-password before closing this session - 'sudo visudo'"
    }
  fi
  # create /etc/sudoers.d/ck_ip_devenv
  SUDOER_CHANGE="${USERNAME} ALL=(ALL) NOPASSWD: ${ROOT_DIR}/install,${ROOT_DIR}/configure,/etc/cron.weekly/upgrade,/usr/sbin/service,${ROOT_DIR}/scripts/*/configure"
  if [[ "${SUDOER_CHANGE}" != "$(sudo cat /etc/sudoers.d/ck_ip_devenv 2>/dev/null || echo -n '')" ]]; then
    echo "${SUDOER_CHANGE}" | sudo tee "/etc/sudoers.d/ck_ip_devenv"
    sudo chmod 0440 "/etc/sudoers.d/ck_ip_devenv"

    sudo visudo -c -s || {
      Log::fatal "Please check syntax of /etc/sudoers.d/ck_ip_devenv before closing this session - 'sudo visudo'"
    }
  fi

  if [[ "${NON_INTERACTIVE:-0}" = "1" ]]; then
    nonInteractiveAws() {
      (echo >&2 "Aws interactive command disabled and not executed: $*")
    }
    alias aws="nonInteractiveAws"

    nonInteractiveSaml2aws() {
      (echo >&2 "Saml2Aws interactive command disabled and not executed: $*")
    }
    alias saml2aws="nonInteractiveSaml2aws"

    nonInteractiveAwsume() {
      (echo >&2 "Awsume interactive command disabled and not executed: $*")
    }
    alias awsume="nonInteractiveAwsume"
  fi

  # initialize environment variables globally
  if [[ "${INSTALL_UPDATE_ENV:-1}" = "1" ]]; then
    # INSTALL_UPDATE_ENV avoids infinite loop, use a light loadConfig without installUpdateEnv
    installUpdateEnv "${CONF_DIR}" "${LDAP_LOGIN}" "${WINDOWS_PROFILE_DIR}"
  fi
}

installUpdateEnv() {
  CONF_DIR="$1"
  LDAP_LOGIN="$2"
  WINDOWS_PROFILE_DIR="$3"

  if [[ ! -f '/etc/profile.d/updateEnv.sh' || "${CONF_DIR}/etc/profile.d/updateEnv.sh" -nt "/etc/profile.d/updateEnv.sh" ]]; then
    Functions::asRootIfNeeded bash -c "INSTALL_UPDATE_ENV=0 source '${LIB_DIR}/common.sh' && OVERWRITE_CONFIG_FILES=1 installFile '${CONF_DIR}/etc/profile.d' '/etc/profile.d' 'updateEnv.sh' setUserRoot"
  fi
  if [[ "$(perl -ne 'if (/export LDAP_LOGIN=(.*)/) { print $1 }' "/etc/profile.d/updateEnv.sh")" != "${LDAP_LOGIN}" ]]; then
    Functions::asRootIfNeeded sed -i -e "s#export LDAP_LOGIN=.*\$#export LDAP_LOGIN=${LDAP_LOGIN}#g" "/etc/profile.d/updateEnv.sh"
  fi
  Functions::asRootIfNeeded sed -i -e "s#WINDOWS_PROFILE_DIR=.*\$#WINDOWS_PROFILE_DIR='${WINDOWS_PROFILE_DIR}'#" "/etc/profile.d/updateEnv.sh"

  # reload env
  set +o errexit
  # shellcheck source=/dev/null
  source "/etc/profile"
  set -o errexit

  # IPCONFIG - which ipconfig.exe does not work when executed as root
  if [[ -z "${IPCONFIG+xxx}" ]]; then
    if Functions::isWsl; then
      IPCONFIG="${BASE_MNT_C}/WINDOWS/system32/ipconfig.exe"
      if ! command -v "${IPCONFIG}" >/dev/null 2>&1; then
        IPCONFIG="$(command -v ipconfig.exe 2>/dev/null)"
      fi
    else
      IPCONFIG="${IPCONFIG:-$(command -v ipconfig)}"
    fi
  fi
  if [[ -z "${IPCONFIG:-}" ]]; then
    Log::fatal "command ipconfig.exe not found"
  fi
  command -v "${IPCONFIG}" >/dev/null 2>&1 || Log::fatal "command ipconfig not found"
  export IPCONFIG
}
