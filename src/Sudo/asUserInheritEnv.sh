#!/usr/bin/env bash

Sudo::asUserInheritEnv() {
  # shellcheck disable=SC2153
  sudo -i -u "${USERNAME}" bash -c "$*"
}
