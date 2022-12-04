#!/usr/bin/env bash

Sudo::asUserInheritEnv() {
  sudo -i -u "${USERNAME}" bash -c "$*"
}
