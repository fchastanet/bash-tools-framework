#!/usr/bin/env bash

COMMAND_BIN_DIR="${FRAMEWORK_ROOT_DIR}/bin"

runContainer() {
  local image="scrasnups/build:bash-tools-ubuntu-5.3"
  local -a dockerRunCmd=(
    "/bash/bin/doc"
    "${BASH_FRAMEWORK_ARGV_FILTERED[@]}"
  )

  if ! docker inspect --type=image "${image}" &>/dev/null; then
    docker pull "${image}"
  fi
  # run docker image
  local -a localDockerRunArgs=(
    --rm
    -e KEEP_TEMP_FILES="${KEEP_TEMP_FILES:-0}"
    -e BATS_FIX_TEST="${BATS_FIX_TEST:-0}"
    -w /bash
    -v "${FRAMEWORK_ROOT_DIR}:/bash"
    --entrypoint /usr/local/bin/bash
  )
  # shellcheck disable=SC2154
  if [[ "${optionContinuousIntegrationMode}" = "0" ]]; then
    localDockerRunArgs+=(
      -e USER_ID="${USER_ID:-1000}"
      -e GROUP_ID="${GROUP_ID:-1000}"
      --user "www-data:www-data"
      -v "/tmp:/tmp"
    )
  fi

  # shellcheck disable=SC2154
  if [[ "${optionTraceVerbose}" = "1" ]]; then
    set -x
  fi
  docker run \
    "${localDockerRunArgs[@]}" \
    "${image}" \
    "${dockerRunCmd[@]}"
  set +x
}

generateDoc() {
  PAGES_DIR="${FRAMEWORK_ROOT_DIR}/pages"
  export FRAMEWORK_ROOT_DIR

  #-----------------------------
  # doc generation
  #-----------------------------

  Log::displayInfo 'generate Commands.md'
  ((TOKEN_NOT_FOUND_COUNT = 0)) || true
  ShellDoc::generateMdFileFromTemplate \
    "${FRAMEWORK_ROOT_DIR}/doc/templates/Commands.tmpl.md" \
    "${PAGES_DIR}/Commands.md" \
    "${COMMAND_BIN_DIR}" \
    TOKEN_NOT_FOUND_COUNT \
    '(var|simpleBinary|shdoc|installFacadeExample)$'

  # clean folder before generate
  rm -f "${PAGES_DIR}/Index.md" || true
  rm -Rf "${PAGES_DIR}/bashDoc" || true
  rm -Rf "${PAGES_DIR}/FrameworkIndex.md" || true

  ShellDoc::generateShellDocsFromDir \
    "${FRAMEWORK_SRC_DIR}" \
    "src" \
    "${PAGES_DIR}/bashDoc" \
    "${PAGES_DIR}/FrameworkIndex.md" \
    "<% ${REPOSITORY_URL} %>" \
    '/testsData|/_.*' \
    '(/__all\.sh)$'
  cp "${FRAMEWORK_ROOT_DIR}/doc/guides/Docker.md" "${PAGES_DIR}/bashDoc/DockerUsage.md"

  cp "${FRAMEWORK_ROOT_DIR}/README.md" "${PAGES_DIR}"
  sed -i -E \
    -e '/<!-- remove -->/,/<!-- endRemove -->/d' \
    -e 's#https://fchastanet.github.io/bash-tools-framework/#/#' \
    -e 's#^> \*\*_TIP:_\*\* (.*)$#> [!TIP|label:\1]#' \
    "${PAGES_DIR}/README.md"

  cp -R "${FRAMEWORK_ROOT_DIR}/doc" "${PAGES_DIR}"
  rm -Rf "${PAGES_DIR}/doc/guides/templates"

  Log::displayInfo 'generate FrameworkFullDoc.md'
  cp "${FRAMEWORK_ROOT_DIR}/doc/templates/FrameworkFullDoc.tmpl.md" "${PAGES_DIR}/FrameworkFullDoc.md"
  (
    echo
    find "${PAGES_DIR}/bashDoc" -type f -name '*.md' -print0 | LC_ALL=C sort -z | xargs -0 cat
  ) >>"${PAGES_DIR}/FrameworkFullDoc.md"

  while read -r path; do
    ShellDoc::fixMarkdownToc "${path}"
  done < <(find "${PAGES_DIR}" -type f -name '*.md')

  if ((TOKEN_NOT_FOUND_COUNT > 0)); then
    exit 1
  fi
}

installRequirements() {
  Git::requireGitCommand
}

installContainerRequirements() {
  Git::requireGitCommand
  ShellDoc::installRequirementsIfNeeded
  Linux::requireJqCommand
  Softwares::installHadolint
  Softwares::installShellcheck
}

if [[ "${IN_BASH_DOCKER:-}" = "You're in docker" ]]; then
  installRequirements
  generateDoc
else
  installContainerRequirements
  runContainer
fi
