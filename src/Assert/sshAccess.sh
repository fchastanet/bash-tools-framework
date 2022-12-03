#!/usr/bin/env bash

Assert::sshAccess() {
  Functions::asUserInheritEnv ssh \
    -q \
    -o PubkeyAuthentication=yes \
    -o PasswordAuthentication=no \
    -o KbdInteractiveAuthentication=no \
    -o ChallengeResponseAuthentication=no \
    "$@" exit
}
