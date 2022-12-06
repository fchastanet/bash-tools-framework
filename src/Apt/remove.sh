#!/usr/bin/env bash

Apt::remove() {
  Retry::default dpkg --purge "$@"
}
