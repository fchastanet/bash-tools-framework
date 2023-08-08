#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Github/getLatestVersionFromUrl.sh
source "${srcDir}/Github/getLatestVersionFromUrl.sh"
# shellcheck source=src/Github/extractRepoFromGithubUrl.sh
source "${srcDir}/Github/extractRepoFromGithubUrl.sh"

function setup() {
  export BASH_FRAMEWORK_DISPLAY_LEVEL=3
}

function Github::getLatestVersionFromUrl::invalidUrl { #@test
  run Github::getLatestVersionFromUrl "invalidUrl"
  assert_output ""
}

function Github::getLatestVersionFromUrl::validUrl { #@test
  Github::getLatestRelease() {
    local repo="$1"
    local -n resultRef=$2
    [[ "${repo}" = "kubernetes-sigs/kind" ]]
    resultRef="v1.0.0"
  }
  local status
  local result
  result=$(
    Github::getLatestVersionFromUrl \
      "https://github.com/kubernetes-sigs/kind/releases/download/@latestVersion@/kind-linux-amd64" \
      2>&1
  )
  status=$?

  [[ "${status}" = "0" ]]
  [[ "$(wc -l <<<"${result}")" = "2" ]]
  [[ "$(sed '1q;d' <<<"${result}")" =~ "INFO    - Repo kubernetes-sigs/kind latest version found is v1.0.0" ]]
  [[ "$(sed '2q;d' <<<"${result}")" = "v1.0.0" ]]
}
