#!/usr/bin/env bash

UI::removeAnsiCodes() {
  sed -E 's/\x1b\[[0-9;]*m//g'
}
