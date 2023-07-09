#!/usr/bin/env bash

Framework::loadConfig() {
  Conf::loadNearestFile ".framework-config" "$@"
}
