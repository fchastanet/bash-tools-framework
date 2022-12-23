#!/usr/bin/env bash

UI::escapeColorCodes() {
  cat - | sed -E $'s/\e\\[[0-9;:]*[a-zA-Z]//g'
}
