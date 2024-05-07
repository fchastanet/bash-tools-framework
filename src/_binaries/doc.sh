#!/usr/bin/env bash
# BIN_FILE=${FRAMEWORK_ROOT_DIR}/bin/doc
# VAR_RELATIVE_FRAMEWORK_DIR_TO_CURRENT_DIR=..
# FACADE

.INCLUDE "$(dynamicTemplateDir _binaries/options/command.doc.tpl)"

docCommand parse "${BASH_FRAMEWORK_ARGV[@]}"

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
    '(bash-tpl|buildBinFilesTmp|var|simpleBinary|shdoc|installFacadeExample)$'

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

  declare -a optionsDocs=(
    "generateGroup"
    "generateOption"
    "generateArg"
    "generateCommand"
  )
  for file in "${optionsDocs[@]}"; do
    "${FRAMEWORK_VENDOR_DIR}/shdoc/shdoc" \
      <"${FRAMEWORK_SRC_DIR}/Options/${file}.sh" \
      >"${FRAMEWORK_ROOT_DIR}/doc/guides/Options/${file}.md"
    # make pre-commit happy
    sed -i -E -e '${/^$/d;}' "${FRAMEWORK_ROOT_DIR}/doc/guides/Options/${file}.md"
  done

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
  ShellDoc::installRequirementsIfNeeded
  Softwares::installHadolint
  Softwares::installShellcheck
}

run() {
  if [[ "${IN_BASH_DOCKER:-}" != "You're in docker" ]]; then
    installRequirements
    runContainer
  else
    generateDoc
  fi
}

if [[ "${BASH_FRAMEWORK_QUIET_MODE:-0}" = "1" ]]; then
  run &>/dev/null
else
  run
fi
