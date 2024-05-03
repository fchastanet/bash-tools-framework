#!/usr/bin/env bash

set -x
set -o errexit
set -o pipefail

if [[ "${SKIP_USER:-0}" = "0" && "${USER_ID:-0}" != "0" && "${GROUP_ID:-0}" != "0" ]]; then
  # del all users with group Id and the del group id
  awk -F: "\$4 == ${GROUP_ID} {print \$1}" /etc/passwd |
    while read -r user; do
      userdel "${user}"
    done
  groupdel "${GROUP_ID}" || true
  # create www-data user and group from scratch
  userdel -f www-data || true
  groupdel www-data || true
  groupadd -g "${GROUP_ID}" www-data
  useradd -l -u "${USER_ID}" -g www-data www-data
  install -d -m 0755 -o www-data -g www-data /home/www-data
  # remove parallel nagware
  mkdir -p /home/www-data/.parallel
  touch /home/www-data/.parallel/will-cite
fi
