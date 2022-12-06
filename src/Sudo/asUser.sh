#!/usr/bin/env bash

Sudo::asUser() {
  sudo -u "${USERNAME}" bash -c "$*"
}
