#!/usr/bin/env bash

set -x
set -o errexit
set -o pipefail

if [[ "${SKIP_USER:-0}" = "0" && "${USER_ID:-0}" != "0" && "${GROUP_ID:-0}" != "0" ]]; then
  # del all users with group Id and the del group id
  awk -F: "\$4 == ${GROUP_ID} {print \$1}" /etc/passwd |
    while read -r user; do
      deluser "${user}"
    done
  delgroup "${GROUP_ID}" || true
  # create www-data user and group from scratch
  delgroup www-data || true
  deluser www-data || true
  addgroup -g "${GROUP_ID}" -S www-data
  adduser -u "${USER_ID}" -D -S -h /app -s /sbin/nologin -G www-data www-data
  # remove parallel nagware
  mkdir -p /app/.parallel
  touch /app/.parallel/will-cite
fi
