#!/usr/bin/env bash

UI::removeAnsiCodes() {
  sed 's/\x1b\[[0-9;]*m//g'
}
