#!/usr/bin/env bash

# github repository eg: kubernetes-sigs/kind
# @param {String} githubUrl eg: https://github.com/kubernetes-sigs/kind/releases/download/@latestVersion@/kind-linux-amd64
# @return 1 if no matching repo found in provided url, 0 otherwise
# @output the repo in the form owner/repo
Github::extractRepoFromGithubUrl() {
  local githubUrl="$1"
  local result
  result="$(sed -n -E 's#^https://github.com/([^/]+/[^/]+)/.*$#\1#p' <<<"${githubUrl}")"
  if [[ -z "${result}" ]]; then
    return 1
  fi
  echo "${result}"
}
