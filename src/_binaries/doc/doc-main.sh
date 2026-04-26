#!/usr/bin/env bash
# @embed "${FRAMEWORK_ROOT_DIR}/src/_binaries/mermaid/mermaid-help.txt" AS mermaidCommandHelp
# @embed "${FRAMEWORK_ROOT_DIR}/src/_binaries/rimageWrapper/rimageWrapper-help.txt" AS rimageWrapperCommandHelp
# @embed "${FRAMEWORK_ROOT_DIR}/src/_binaries/krokiWrapper/krokiWrapper-help.txt" AS krokiWrapperCommandHelp
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

generateBinary() {
  local binaryName="$1"
  local commandName="$2"
  local binaryDir="${PERSISTENT_TMPDIR}/${binaryName}"
  local binaryPath="${binaryDir}/${binaryName}"
  local embedFileVarName="embed_file_${commandName}CommandHelp"
  mkdir -p "${binaryDir}"
  (
    echo '#!/usr/bin/env bash'
    # shellcheck disable=SC2016
    echo 'echo <<<EOF'
    # shellcheck disable=SC2154
    cat "${!embedFileVarName}"
    echo 'EOF'
  ) >"${binaryPath}"
  chmod +x "${binaryPath}"
  export PATH="${binaryDir}:${PATH}"
}

generateDoc() {
  PAGES_DIR="${FRAMEWORK_ROOT_DIR}/content"
  export FRAMEWORK_ROOT_DIR

  #-----------------------------
  # doc generation
  #-----------------------------
  Log::displayInfo 'generate Commands.md'
  ((TOKEN_NOT_FOUND_COUNT = 0)) || true
  generateBinary "npx" "mermaid"
  generateBinary "rimageWrapper" "rimageWrapper"
  generateBinary "krokiWrapper" "krokiWrapper"

  export KROKI_DIR="${TMPDIR}/kroki"
  export SKIP_KROKI_PULL=1

  ShellDoc::generateMdFileFromTemplate \
    "${FRAMEWORK_ROOT_DIR}/doc/templates/Commands.tmpl.md" \
    "${PAGES_DIR}/Commands.md" \
    "${COMMAND_BIN_DIR}" \
    TOKEN_NOT_FOUND_COUNT \
    '(var|simpleBinary|shdoc|installFacadeExample)$'
  if ((TOKEN_NOT_FOUND_COUNT > 0)); then
    exit 1
  fi

  # clean folder before generate
  rm -f "${PAGES_DIR}/Index.md" || true
  rm -Rf "${PAGES_DIR}/bashDoc" || true

  ShellDoc::generateShellDocsFromDir \
    "${FRAMEWORK_SRC_DIR}" \
    "src" \
    "${PAGES_DIR}/bashDoc" \
    "${PAGES_DIR}/_index.md" \
    "${REPOSITORY_URL}" \
    '/testsData|/_.*' \
    '(/__all\.sh)$' \
    "${FRAMEWORK_ROOT_DIR}/doc/templates/FrameworkDirectoryIndex.tmpl.md"

  mkdir -p "${PAGES_DIR}/assets"
  cp -v \
    "${FRAMEWORK_ROOT_DIR}/src/Env/requireLoad-activityDiagram.svg" \
    "${PAGES_DIR}/assets"
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
