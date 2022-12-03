#!/usr/bin/env bash

Wsl::cachedWslpathFromWslVar() {
  local var="$1"
  local value
  value="$(Wsl::cachedWslvar "${var}")"
  Wsl::cachedWslpath "${value}"
}
