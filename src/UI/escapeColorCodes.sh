#!/usr/bin/env bash

UI::escapeColorCodes() {
  cat - | sed $'s/\e\\[[0-9;:]*[a-zA-Z]//g'
}
