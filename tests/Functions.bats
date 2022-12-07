#!/usr/bin/env bash

ROO_DIR="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
# shellcheck source=/src/Framework/loadEnv.sh
BASH_FRAMEWORK_ENV_FILEPATH="" source "${ROO_DIR}/src/Framework/loadEnv.sh" || exit 1

load "${ROO_DIR}/vendor/bats-mock-Flamefire/load.bash"

setup() {
  mkdir -p /tmp/home/.bash-tools/cliProfiles
  mkdir -p /tmp/home/.bash-tools/dsn
  cp -v "${ROO_DIR}/conf/cliProfiles/default.sh" /tmp/home/.bash-tools/cliProfiles
}

teardown() {
  rm -Rf /tmp/home || true
  unstub_all
}

function functions_framework_is_loaded { #@test
  [[ "${BASH_FRAMEWORK_INITIALIZED}" = "1" ]]
}

function functions_assert_windows { #@test
  unameMocked() {
    echo "Msys"
  }
  alias uname="unameMocked"

  [[ "$(Assert::windows)" = "1" ]]
}

function functions_checkDnsHostname_localhost { #@test
  unameMocked() {
    echo "Linux"
  }
  alias uname="unameMocked"

  pingMocked() {
    echo "PING willywonka.fchastanet.lan (127.0.1.1) 56(84) bytes of data."
    return 0
  }
  alias ping="pingMocked"

  if ! Functions::checkDnsHostname "willywonka.fchastanet.lan"; then
    false
  fi
}

function functions_checkDnsHostname_external_host { #@test
  unameMocked() {
    echo "Linux"
  }
  alias uname="unameMocked"

  pingMocked() {
    echo "PING willywonka.fchastanet.lan (192.168.1.1) 56(84) bytes of data."
    return 0
  }
  alias ping="pingMocked"

  ifconfigMocked() {
    echo "eth4: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500"
    echo "inet 192.168.1.1  netmask 255.255.0.0  broadcast 192.168.255.255"
    return 0
  }
  alias ifconfig="ifconfigMocked"
  Functions::checkDnsHostname "willywonka.fchastanet.lan" || false
}

function assert_commandExists_exists { #@test
  (Assert::commandExists "bash") || false
}

function assert_commandExists_not_exists { #@test
  run Assert::commandExists "qsfdsfds"
  # shellcheck disable=SC2154
  [[ "${status}" -eq 1 ]]
  # shellcheck disable=SC2154
  [[ "${lines[0]}" = "$(echo -e "${__ERROR_COLOR}ERROR - qsfdsfds is not installed, please install it${__RESET_COLOR}")" ]]
}

function functions_getList { #@test
  run Profiles::list "${BATS_TEST_DIRNAME}/dataGetList" "sh"
  [[ "${status}" -eq 0 ]]
  [[ "${#lines[@]}" = "2" ]]
  [[ "${lines[0]}" = "       - test" ]]
  [[ "${lines[1]}" = "       - test2" ]]

  run Profiles::list "${BATS_TEST_DIRNAME}/dataGetList" "sh" "-"
  [[ "${status}" -eq 0 ]]
  [[ "${#lines[@]}" = "2" ]]
  [[ "${lines[0]}" = "-test" ]]
  [[ "${lines[1]}" = "-test2" ]]

  run Profiles::list "${BATS_TEST_DIRNAME}/dataGetList" "dsn" "*"
  [[ "${status}" -eq 0 ]]
  # shellcheck disable=SC2154
  [[ "${output}" = "*hello" ]]

  run Profiles::list "${BATS_TEST_DIRNAME}/unknown" "sh" "*"
  [[ "${status}" -eq 1 ]]
}

function profiles_loadConf_absolute_file { #@test
  Profiles::loadConf "anyFolder" "/tmp/home/.bash-tools/cliProfiles/default.sh"
  # shellcheck disable=SC2154
  [[ "${finalUserArg}" = "www-data" ]]
  # shellcheck disable=SC2154
  [[ "${finalCommandArg}" = "//bin/bash" ]]
  # shellcheck disable=SC2154
  [[ "${finalContainerArg}" = "project-apache2" ]]
}

function profiles_loadConf_default { #@test
  Profiles::loadConf "cliProfiles" "default"
  # shellcheck disable=SC2154
  [[ "${finalUserArg}" = "www-data" ]]
  # shellcheck disable=SC2154
  [[ "${finalCommandArg}" = "//bin/bash" ]]
  # shellcheck disable=SC2154
  [[ "${finalContainerArg}" = "project-apache2" ]]
}

function profiles_loadConf_dsn { #@test
  Profiles::loadConf "dsn" "default.local" ".env"
  [[ "${HOSTNAME}" = "127.0.0.1" ]]
  [[ "${USER}" = "root" ]]
  [[ "${PASSWORD}" = "root" ]]
  [[ "${PORT}" = "3306" ]]
}

function profiles_loadConf_file_not_found { #@test
  run Profiles::loadConf "dsn" "not found" ".sh"
  [[ "${status}" -eq 1 ]]
}

function profiles_getConfMergedList { #@test
  cp -v "${FRAMEWORK_DIR}/conf/dsn/"* /tmp/home/.bash-tools/dsn
  touch /tmp/home/.bash-tools/dsn/dsn_invalid_port.env
  touch /tmp/home/.bash-tools/dsn/otherInvalidExt.ext
  touch /tmp/home/.bash-tools/dsn/otherInvalidExt2.sh

  HOME=/tmp/home run Profiles::getConfMergedList "dsn" "env"
  [[ "$(cat "${BATS_TEST_DIRNAME}/data/database.dsnList1")" = "${output}" ]]
}

function profiles_getAbsoluteConfFile_env_file_from_home { #@test
  touch /tmp/home/.bash-tools/dsn/dsn_invalid_port.env

  HOME=/tmp/home run Profiles::getAbsoluteConfFile "dsn" "dsn_invalid_port" "env"
  [[ "${status}" -eq 0 ]]
  [[ "/tmp/home/.bash-tools/dsn/dsn_invalid_port.env" = "${output}" ]]
}

function profiles_getAbsoluteConfFile_sh_file_from_home_default_extension { #@test
  touch /tmp/home/.bash-tools/dsn/otherInvalidExt2.sh

  HOME=/tmp/home run Profiles::getAbsoluteConfFile "dsn" "otherInvalidExt2"
  [[ "${status}" -eq 0 ]]
  [[ "/tmp/home/.bash-tools/dsn/otherInvalidExt2.sh" = "${output}" ]]
}

function profiles_getAbsoluteConfFile_file_default_in_conf_folder { #@test
  HOME=/tmp/home run Profiles::getAbsoluteConfFile "dsn" "default.local" "env"
  [[ "${status}" -eq 0 ]]
  [[ "${FRAMEWORK_DIR}/conf/dsn/default.local.env" = "${output}" ]]
}

function profiles_getAbsoluteConfFile_relative_file { #@test
  mkdir -p /tmp/home/.bash-tools/data
  touch /tmp/home/.bash-tools/data/dsn_valid.env

  HOME=/tmp/home run Profiles::getAbsoluteConfFile "data" "../../../../tests/bash-framework/data/dsn_valid.env" "sh"

  [[ "${status}" -eq 0 ]]
  [[ "${BATS_TEST_DIRNAME}/data/dsn_valid.env" = "${output}" ]]
}

function profiles_getAbsoluteConfFile_absolute_file_ignores_confFolder_and_ext { #@test
  touch /tmp/home/.bash-tools/dsn/otherInvalidExt.ext

  HOME=/tmp/home run Profiles::getAbsoluteConfFile "data" "/tmp/home/.bash-tools/dsn/otherInvalidExt.ext" "sh"
  [[ "${status}" -eq 0 ]]
  [[ "/tmp/home/.bash-tools/dsn/otherInvalidExt.ext" = "${output}" ]]
}

function profiles_getAbsoluteConfFile_absolute_file_ignores_confFolder_and_ext2 { #@test
  touch /tmp/home/.bash-tools/dsn/dsn_invalid_port.sh

  HOME=/tmp/home run Profiles::getAbsoluteConfFile "data" "/tmp/home/.bash-tools/dsn/dsn_invalid_port.sh" "env"
  [[ "${status}" -eq 0 ]]
  [[ "/tmp/home/.bash-tools/dsn/dsn_invalid_port.sh" = "${output}" ]]
}

function profiles_getAbsoluteConfFile_absolute_file_ignores_confFolder_and_ext3 { #@test
  touch /tmp/home/.bash-tools/dsn/otherInvalidExt2.sh

  HOME=/tmp/home run Profiles::getAbsoluteConfFile "data" "/tmp/home/.bash-tools/dsn/otherInvalidExt2.sh" "env"
  [[ "${status}" -eq 0 ]]
  [[ "/tmp/home/.bash-tools/dsn/otherInvalidExt2.sh" = "${output}" ]]
}

function profiles_getAbsoluteConfFile_file_without_extension { #@test
  touch /tmp/home/.bash-tools/dsn/noExtension

  HOME=/tmp/home run Profiles::getAbsoluteConfFile "dsn" "noExtension" ""
  [[ "${status}" -eq 0 ]]
  [[ "/tmp/home/.bash-tools/dsn/noExtension" = "${output}" ]]
}

function profiles_getAbsoluteConfFile_file_not_found { #@test
  touch /tmp/home/.bash-tools/dsn/otherInvalidExt2.sh

  HOME=/tmp/home run Profiles::getAbsoluteConfFile "dsn" "invalidFile" "env"
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == *"conf file 'invalidFile' not found"* ]]
}

function framework_trapAdd { #@test
  trap 'echo "SIGUSR1 original" >> /tmp/home/trap' SIGUSR1
  Framework::trapAdd 'echo "SIGUSR1 overriden" >> /tmp/home/trap' SIGUSR1
  kill -SIGUSR1 $$
  [[ "$(cat /tmp/home/trap)" = "$(cat "${BATS_TEST_DIRNAME}/data/Functions_addTrap_expected")" ]]
}

function framework_trapAdd_2_events_at_once { #@test
  trap 'echo "SIGUSR1 original" >> /tmp/home/trap' SIGUSR1
  trap 'echo "SIGUSR2 original" >> /tmp/home/trap' SIGUSR2
  Framework::trapAdd 'echo "SIGUSR1&2 overriden" >> /tmp/home/trap' SIGUSR1 SIGUSR2
  kill -SIGUSR1 $$
  [[ "$(cat /tmp/home/trap)" = "$(cat "${BATS_TEST_DIRNAME}/data/Functions_addTrap2_1_expected")" ]]
  rm /tmp/home/trap
  kill -SIGUSR2 $$
  [[ "$(cat /tmp/home/trap)" = "$(cat "${BATS_TEST_DIRNAME}/data/Functions_addTrap2_2_expected")" ]]
}

function framework_run_status_0 { #@test
  stub date \
    '* : echo 1609970133' \
    '* : echo 1609970134'

  Framework::run echo 'coucou' 2>/tmp/home/error
  # shellcheck disable=SC2154
  [[ "${bash_framework_status}" -eq 0 ]]
  # shellcheck disable=SC2154
  [[ "${bash_framework_duration}" = "1" ]]
  # shellcheck disable=SC2154
  [[ "${bash_framework_output}" = "coucou" ]]
  [[ "$(cat /tmp/home/error)" = "" ]]
}

function framework_run_status_1 { #@test
  stub date \
    '* : echo 1609970133' \
    '* : echo 1609970134'

  Framework::run cat 'unknownFile' 2>/tmp/home/error

  # shellcheck disable=SC2154
  [[ "${bash_framework_status}" -eq 1 ]]
  # shellcheck disable=SC2154
  [[ "${bash_framework_duration}" = "1" ]]
  # shellcheck disable=SC2154
  [[ "${bash_framework_output}" = "" ]]
  [[ "$(cat /tmp/home/error)" == *"cat: "* ]]
  [[ "$(cat /tmp/home/error)" == *"unknownFile"* ]]
  [[ "$(cat /tmp/home/error)" == *": No such file or directory" ]]
}
