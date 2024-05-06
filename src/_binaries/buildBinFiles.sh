#!/usr/bin/env bash
# BIN_FILE=${FRAMEWORK_ROOT_DIR}/bin/buildBinFiles
# VAR_RELATIVE_FRAMEWORK_DIR_TO_CURRENT_DIR=..
# FACADE

.INCLUDE "$(dynamicTemplateDir _binaries/options/command.buildBinFiles.tpl)"

buildBinFilesCommand parse "${BASH_FRAMEWORK_ARGV[@]}"

declare beforeBuild
computeMd5File() {
  local md5File="$1"
  shift || true
  local -a files=("$@")
  local -a binFiles
  readarray -t binFiles <<<"$(getBinFiles "${files[@]}")"
  local file
  for file in "${binFiles[@]}"; do
    md5sum "${file}" >>"${md5File}" 2>&1 || true
  done
}

getBinFiles() {
  local -a files=("$@")
  (
    grep -R "^# BIN_FILE" "${files[@]}" |
      (grep -v -E '/testsData/' || true) |
      sed -E 's#^.*IN_FILE=(.*)$#\1#'
  ) | FRAMEWORK_ROOT_DIR=$(pwd -P) envsubst
}

getFiles() {
  local -a files=("$@")
  if ((${#files[@]} == 0)); then
    # shellcheck disable=SC2154
    grep --include=\*.sh -rlw -e "^# BIN_FILE" "${optionSrcDirs[@]}" |
      (grep -v -E '/testsData/' || true)
  else
    for file in "${files[@]}"; do
      realpath "${file}"
    done
  fi
}

buildBinFiles() {
  declare -a files=()
  # shellcheck disable=SC2154
  for arg in "${buildBinFilesArgs[@]}"; do
    if [[ "${arg}" =~ .sh$ ]]; then
      files+=("${arg}")
    else
      params+=("${arg}")
    fi
  done
  readarray -t files <<<"$(getFiles "${files[@]}")"

  # shellcheck disable=SC2154
  if [[ "${optionContinuousIntegrationMode}" = "1" ]]; then
    beforeBuild="$(mktemp -p "${TMPDIR:-/tmp}" -t bash-tools-buildBinFiles-before-XXXXXX)"
    computeMd5File "${beforeBuild}" "${files[@]}"
    cat "${beforeBuild}"
  fi
  printf "%s\n" "${files[@]}" | xargs -t -P8 --max-args=1 --replace="{}" \
    "${FRAMEWORK_BIN_DIR}/compile" "{}" "${COMPILE_PARAMETERS[@]}" "${params[@]}"

  # allows to add ignore missing option to md5sum when using pre-commit
  declare -a args=()
  # shellcheck disable=SC2154
  if [[ "${optionIgnoreMissing}" = "1" ]]; then
    args+=(--ignore-missing)
  fi
  # exit with code != 0 if at least one bin file has changed
  if [[ "${optionContinuousIntegrationMode}" = "1" ]] &&
    ! md5sum -c "${args[@]}" "${beforeBuild}"; then
    echo >&2 "some bin files need to be committed"
    exit 1
  fi
}

runContainer() {
  local image="scrasnups/build:bash-tools-ubuntu-5.3"

  if ! docker inspect --type=image "${image}" &>/dev/null; then
    docker pull "${image}"
  fi

  # run docker image
  local -a localDockerRunArgs=(
    --rm
    -w /bash
    -v "$(pwd):/bash"
    --entrypoint /usr/local/bin/bash
  )
  # shellcheck disable=SC2154
  if Assert::tty; then
    localDockerRunArgs+=(-v "/tmp:/tmp")
    localDockerRunArgs+=(-it)
  fi
  if [[ -n "${USER_ID:-}" ]]; then
    localDockerRunArgs+=(--user "${USER_ID}:${GROUP_ID}")
  fi
  localDockerRunArgs+=(
    -v "${REAL_SCRIPT_FILE}:/bash/bin/${SCRIPT_NAME}"
  )
  localDockerRunArgs+=(-e KEEP_TEMP_FILES="${KEEP_TEMP_FILES:-0}")

  docker run \
    "${localDockerRunArgs[@]}" \
    "${image}" \
    "/bash/bin/${SCRIPT_NAME}" \
    "${ORIGINAL_BASH_FRAMEWORK_ARGV[@]}"

}

run() {
  if [[ "${IN_BASH_DOCKER:-}" != "You're in docker" ]]; then
    runContainer
  else
    buildBinFiles
  fi
}

if [[ "${BASH_FRAMEWORK_QUIET_MODE:-0}" = "1" ]]; then
  run &>/dev/null
else
  run
fi
