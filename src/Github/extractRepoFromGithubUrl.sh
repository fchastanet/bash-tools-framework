#!/usr/bin/env bash

# github repository eg: kubernetes-sigs/kind
# @param {String} githubUrl eg: https://github.com/kubernetes-sigs/kind/releases/download/@latestVersion@/kind-linux-amd64
Github::extractRepoFromGithubUrl() {
  local githubUrl="$1"
  echo "${githubUrl}" | sed -E 's#^https://github.com/([^/]+)/([^/]+)/.*$#\1/\2#'
}
