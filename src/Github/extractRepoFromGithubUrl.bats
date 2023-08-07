#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Github/extractRepoFromGithubUrl.sh
source "${srcDir}/Github/extractRepoFromGithubUrl.sh"

function Github::extractRepoFromGithubUrl::invalidUrl { #@test
  run Github::extractRepoFromGithubUrl "invalidUrl"
  assert_failure 1
  assert_output ""
}

function Github::extractRepoFromGithubUrl::incompleteUrl { #@test
  run Github::extractRepoFromGithubUrl "https://github.com/kubernetes-sigs/kind"
  assert_failure 1
  assert_output ""
}

function Github::extractRepoFromGithubUrl::validUrl { #@test
  run Github::extractRepoFromGithubUrl "https://github.com/kubernetes-sigs/kind/releases/download/@latestVersion@/kind-linux-amd64"
  assert_success
  assert_output "kubernetes-sigs/kind"
}
