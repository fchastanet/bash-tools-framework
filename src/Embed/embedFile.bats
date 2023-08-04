#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd -P)/batsHeaders.sh"

# shellcheck source=src/Embed/embedFile.sh
source "${srcDir}/Embed/embedFile.sh"
# shellcheck source=src/Embed/extractFileFromBase64.sh
source "${srcDir}/Embed/extractFileFromBase64.sh"
# shellcheck source=src/Env/pathPrepend.sh
source "${srcDir}/Env/pathPrepend.sh"

setup() {
  export TMPDIR="${BATS_TEST_TMPDIR}"
  export PATH="${TMPDIR}/bin":${PATH}
  export _COMPILE_ROOT_DIR="${ROOT_DIR}"
  export PERSISTENT_TMPDIR="${BATS_TEST_TMPDIR}"
}

function Embed::embedFile::binaryFile { #@test
  local md5sum
  md5sum="$(md5sum "${BATS_TEST_DIRNAME}/testsData/binaryFile" | awk '{print $1}')"
  (
    echo "#!/usr/bin/env bash"
    Embed::embedFile "${BATS_TEST_DIRNAME}/testsData/binaryFile" "binaryFile"
  ) >"${BATS_TEST_TMPDIR}/fileIncluded"
  source "${BATS_TEST_TMPDIR}/fileIncluded"

  _COMPILE_ROOT_DIR="${ROOT_DIR}" run binaryFile arg1 arg2

  assert_success
  assert_output "binaryFile arg1 arg2"
  [[ -x "${BATS_TEST_TMPDIR}/${md5sum}/binaryFile" ]]
  # shellcheck disable=SC2154
  [[ "${embed_file_binaryFile}" = "${BATS_TEST_TMPDIR}/${md5sum}/binaryFile" ]]
}

function Embed::embedFile::normalFile { #@test
  local md5sum
  md5sum="$(md5sum "${BATS_TEST_DIRNAME}/testsData/normalFile" | awk '{print $1}')"
  (
    echo "#!/usr/bin/env bash"
    Embed::embedFile "${BATS_TEST_DIRNAME}/testsData/normalFile" "normalFile"
  ) >"${BATS_TEST_TMPDIR}/fileIncluded"
  source "${BATS_TEST_TMPDIR}/fileIncluded"

  [[ ! -x "${BATS_TEST_TMPDIR}/${md5sum}/normalFile" ]]
  [[ "$(head -1 "${BATS_TEST_TMPDIR}/${md5sum}/normalFile")" = "normalFileContent" ]]
  # shellcheck disable=SC2154
  [[ "${embed_file_normalFile}" = "${BATS_TEST_TMPDIR}/${md5sum}/normalFile" ]]
}
