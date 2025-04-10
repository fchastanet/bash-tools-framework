#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Crypto/uuidV4.sh
source "${srcDir}/Crypto/uuidV4.sh"

teardown() {
  unstub_all
}

function Crypto::uuidV4::randomFileExists { #@test
  Crypto_random_file_exists() {
    return 0
  }
  run Crypto::uuidV4 >"${BATS_RUN_TMPDIR}/result" 2>&1
  assert_success
  assert_output --regexp "^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$"
}

function Crypto::uuidV4::randomFileNotExistsButUuidGenExists { #@test
  Crypto_random_file_exists() {
    return 1
  }
  Assert::commandExists() {
    return 0
  }
  stub uuidgen '-r : echo "3a8b2202-d904-4cb0-bdbc-a296c938fedc"'
  run Crypto::uuidV4 2>&1
  assert_success
  assert_output --regexp "^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$"
}

function Crypto::uuidV4::randomFileNotExistsAndUUidGenNeither { #@test
  Crypto_random_file_exists() {
    return 1
  }
  Assert::commandExists() {
    return 1
  }

  run Crypto::uuidV4 >"${BATS_RUN_TMPDIR}/result" 2>&1
  assert_failure 1
  assert_output --partial "ERROR   - unable to generate uuid on that system"
}
