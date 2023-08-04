#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd -P)/batsHeaders.sh"

# shellcheck source=src/Embed/embedDir.sh
source "${BATS_TEST_DIRNAME}/embedDir.sh"
# shellcheck source=src/Embed/extractDirFromBase64.sh
source "${BATS_TEST_DIRNAME}/extractDirFromBase64.sh"

setup() {
  export TMPDIR="${BATS_TEST_TMPDIR}"
  export _COMPILE_ROOT_DIR="${ROOT_DIR}"
  export PERSISTENT_TMPDIR="${BATS_TEST_TMPDIR}"
}

function Embed::embedDir::testsData { #@test
  (
    echo "#!/usr/bin/env bash"
    Embed::embedDir "${BATS_TEST_DIRNAME}/testsData" "testsData"
  ) >"${BATS_TEST_TMPDIR}/dirIncluded"
  source "${BATS_TEST_TMPDIR}/dirIncluded"

  [[ -d "${BATS_TEST_TMPDIR}/testsData" ]]
  [[ -f "${BATS_TEST_TMPDIR}/testsData/binaryFile" ]]
  [[ -f "${BATS_TEST_TMPDIR}/testsData/normalFile" ]]
  # shellcheck disable=SC2154
  [[ "${embed_dir_testsData}" = "${BATS_TEST_TMPDIR}/testsData" ]]
}
