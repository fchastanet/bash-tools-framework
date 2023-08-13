#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Dns/checkHostname.sh
source "${srcDir}/Dns/checkHostname.sh"
# shellcheck source=/src/Command/captureOutputAndExitCode.sh
source "${srcDir}/Command/captureOutputAndExitCode.sh"
# shellcheck source=/src/Assert/windows.sh
source "${srcDir}/Assert/windows.sh"

setup() {
  export BASH_FRAMEWORK_DISPLAY_LEVEL=${__LEVEL_INFO}
  Env::load
  Log::load
}

teardown() {
  unstub_all
}

function Dns::checkHostnameEmptyHost { #@test
  run Dns::checkHostname ""
  assert_failure 1
  assert_output ""
}

function Dns::checkHostnameLocalhost { #@test
  stub uname "-o : echo 'Linux'"
  stub ping "-c 1 willywonka.fchastanet.lan : echo 'PING willywonka.fchastanet.lan (127.0.1.1) 56(84) bytes of data.'"

  run Dns::checkHostname "willywonka.fchastanet.lan"
  assert_success
  assert_lines_count 2
  assert_line --index 0 --partial "INFO    - try to reach host willywonka.fchastanet.lan"
  assert_line --index 1 --partial "PING willywonka.fchastanet.lan (127.0.1.1) 56(84) bytes of data."
}

function Dns::checkHostnameExternalHostLinux { #@test
  stub uname \
    "-o : echo 'Linux'" \
    "-o : echo 'Linux'"
  stub ping "-c 1 willywonka.fchastanet.lan : echo 'PING willywonka.fchastanet.lan (192.168.1.1) 56(84) bytes of data.'"
  stub ifconfig " : cat '${BATS_TEST_DIRNAME}/testsData/ifconfig.txt'"

  run Dns::checkHostname "willywonka.fchastanet.lan"
  assert_success
  assert_lines_count 4
  assert_line --index 0 --partial "INFO    - try to reach host willywonka.fchastanet.lan"
  assert_line --index 1 --partial "PING willywonka.fchastanet.lan (192.168.1.1) 56(84) bytes of data."
  assert_line --index 2 --partial "INFO    - check if ip(192.168.1.1) associated to host(willywonka.fchastanet.lan) is listed in your network configuration"
  assert_line --index 3 --partial "inet 192.168.1.1  netmask 255.255.0.0  broadcast 192.168.255.255"
}

function Dns::checkHostnameExternalHostWindows { #@test
  stub uname \
    "-o : echo 'Msys'" \
    "-o : echo 'Msys'"
  stub ping "-n 1 willywonka.fchastanet.lan : echo 'PING willywonka.fchastanet.lan (192.168.1.1) 56(84) bytes of data.'"
  stub ipconfig " : cat '${BATS_TEST_DIRNAME}/testsData/ipconfig.txt'"

  run Dns::checkHostname "willywonka.fchastanet.lan"
  assert_success
  assert_lines_count 4
  assert_line --index 0 --partial "INFO    - try to reach host willywonka.fchastanet.lan"
  assert_line --index 1 --partial "PING willywonka.fchastanet.lan (192.168.1.1) 56(84) bytes of data."
  assert_line --index 2 --partial "INFO    - check if ip(192.168.1.1) associated to host(willywonka.fchastanet.lan) is listed in your network configuration"
  assert_line --index 3 --partial "IPv4 Address. . . . . . . . . . . : 192.168.1.1"
}
