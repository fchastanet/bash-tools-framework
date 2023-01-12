#!/usr/bin/env bash

Assert::sshAccess() {
  Sudo::asUserInheritEnv ssh \
    -q \
    -o PubkeyAuthentication=yes \
    -o PasswordAuthentication=no \
    -o KbdInteractiveAuthentication=no \
    -o ChallengeResponseAuthentication=no \
    "$@" exit
}
