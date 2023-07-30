#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd -P)/batsHeaders.sh"

# shellcheck source=src/Embed/embedFile.sh
source "${BATS_TEST_DIRNAME}/embedFile.sh"

setup() {
  export TMPDIR="${BATS_TEST_TMPDIR}"
  export PATH="${TMPDIR}/bin":${PATH}
  export _COMPILE_ROOT_DIR="${ROOT_DIR}"
  export PERSISTENT_TMPDIR="${BATS_TEST_TMPDIR}"
}

function Embed::embedFile::binaryFile { #@test
  (
    echo "#!/usr/bin/env bash"
    Embed::embedFile "${BATS_TEST_DIRNAME}/testsData/binaryFile" "binaryFile"
  ) >"${BATS_TEST_TMPDIR}/fileIncluded"
  source "${BATS_TEST_TMPDIR}/fileIncluded"

  _COMPILE_ROOT_DIR="${ROOT_DIR}" run binaryFile arg1 arg2

  assert_success
  assert_output "binaryFile arg1 arg2"
  [[ -x "${BATS_TEST_TMPDIR}/bin/binaryFile" ]]
  # shellcheck disable=SC2154
  [[ "${embed_file_binaryFile}" = "${BATS_TEST_TMPDIR}/bin/binaryFile" ]]
}

function Embed::embedFile::normalFile { #@test
  (
    echo "#!/usr/bin/env bash"
    Embed::embedFile "${BATS_TEST_DIRNAME}/testsData/normalFile" "normalFile"
  ) >"${BATS_TEST_TMPDIR}/fileIncluded"
  source "${BATS_TEST_TMPDIR}/fileIncluded"

  [[ ! -x "${BATS_TEST_TMPDIR}/bin/normalFile" ]]
  [[ "$(head -1 "${BATS_TEST_TMPDIR}/bin/normalFile")" = "normalFileContent" ]]
  # shellcheck disable=SC2154
  [[ "${embed_file_normalFile}" = "${BATS_TEST_TMPDIR}/bin/normalFile" ]]
}
