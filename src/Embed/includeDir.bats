#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd -P)/batsHeaders.sh"

# shellcheck source=src/Embed/includeDir.sh
source "${BATS_TEST_DIRNAME}/includeDir.sh"

setup() {
  export TMPDIR="${BATS_TEST_TMPDIR}"
  export _COMPILE_ROOT_DIR="${ROOT_DIR}"
  export PERSISTENT_TMPDIR="${BATS_TEST_TMPDIR}"
}

function Embed::includeDir::testsData { #@test
  (
    echo "#!/usr/bin/env bash"
    Embed::includeDir "${BATS_TEST_DIRNAME}/testsData" "testsData"
  ) >"${BATS_TEST_TMPDIR}/dirIncluded"
  source "${BATS_TEST_TMPDIR}/dirIncluded"

  [[ -d "${BATS_TEST_TMPDIR}/testsData" ]]
  [[ -f "${BATS_TEST_TMPDIR}/testsData/binaryFile" ]]
  [[ -f "${BATS_TEST_TMPDIR}/testsData/normalFile" ]]
  # shellcheck disable=SC2154
  [[ "${embed_dir_testsData}" = "${BATS_TEST_TMPDIR}/testsData" ]]
}
