#!/usr/bin/env bash

Apt::remove() {
  Retry::default sudo dpkg --purge "$@"
}
