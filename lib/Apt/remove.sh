#!/usr/bin/env bash

Apt::remove() {
  Functions::retry dpkg --purge "$@"
}
