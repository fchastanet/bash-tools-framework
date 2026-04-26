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
  ((TOKEN_NOT_FOUND_COUNT = 0)) || true

  ShellDoc::generateShellDocsFromDir \
    "${FRAMEWORK_SRC_DIR}" \
    "src" \
    "${PAGES_DIR}/bashDoc" \
    "${PAGES_DIR}/_index.md" \
    "${REPOSITORY_URL}" \
    '/testsData|/_.*' \
    '(/__all\.sh)$' \
    "${FRAMEWORK_ROOT_DIR}/assets/templates/FrameworkDirectoryIndex.tmpl.md"

  Log::displayInfo 'generate commands doc ...'
  # clean folder before generate
  rm -f "${PAGES_DIR}/Index.md" || true
  rm -Rf "${PAGES_DIR}/bashDoc" || true

  local templateFile
  local templateBaseName
  for templateFile in "${FRAMEWORK_ROOT_DIR}/assets/templates/Commands-"*.tmpl.md; do
    templateBaseName=$(basename "${templateFile}")
    local token="${templateBaseName#Commands-}"
    token="${token%.tmpl.md}"
    local targetFile="${PAGES_DIR}/commands/${templateBaseName%.tmpl.md}.md"
    cp "${templateFile}" "${targetFile}"
    local binaryPath="${FRAMEWORK_ROOT_DIR}/bin/${token}"
    if [[ "${token}" = "install" ]]; then
      # install command is in root folder
      binaryPath="${FRAMEWORK_ROOT_DIR}/${token}"
    fi
    if [[ ! -x "${binaryPath}" || ! -f "${binaryPath}" ]]; then
      Log::displayError "No executable file found for ${token} command (${binaryPath})"
      ((TOKEN_NOT_FOUND_COUNT++))
      continue
    fi
    Log::displayInfo "generate help for ${token} command"
    local tokenCommandHelpVariable="embed_file_${token}CommandHelp"
    (
      if [[ -n "${!tokenCommandHelpVariable}" ]]; then
        cat "${!tokenCommandHelpVariable}"
      else
        "${binaryPath}" --help
      fi
    ) | File::replaceTokenByInput "@@@${token}_help@@@" "${targetFile}"
  done

  # check if all binaries have their associated template file
  local command
  local commandBaseName
  local excludedCommands=(
    "installFacadeExample"
    "var"
    "simpleBinary"
    "shdoc"
  )
  for command in "${FRAMEWORK_ROOT_DIR}/bin/"*; do
    if [[ -x "${command}" && -f "${command}" ]]; then
      commandBaseName=$(basename "${command}")
      local expectedTemplateFile="${FRAMEWORK_ROOT_DIR}/assets/templates/Commands-${commandBaseName}.tmpl.md"
      if [[ ! -f "${expectedTemplateFile}" ]] && ! Array::contains "${commandBaseName}" "${excludedCommands[@]}"; then
        Log::displayError "No template file found for ${commandBaseName} command (${expectedTemplateFile})"
        ((TOKEN_NOT_FOUND_COUNT++))
      fi
    fi
  done

  if ((TOKEN_NOT_FOUND_COUNT > 0)); then
    Log::displayError "doc generation failed with ${TOKEN_NOT_FOUND_COUNT} errors"
    return 1
  fi

  Log::displayInfo "Copy doc assets"
  mkdir -p "${PAGES_DIR}/assets"
  cp -v \
    "${FRAMEWORK_ROOT_DIR}/src/Env/requireLoad-activityDiagram.svg" \
    "${PAGES_DIR}/assets"

  Log::displayInfo "doc generated successfully in ${PAGES_DIR}"
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
