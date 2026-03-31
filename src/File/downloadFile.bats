#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/File/downloadFile.sh
source "${srcDir}/File/downloadFile.sh"

setup() {
  export TMPDIR="${BATS_TEST_TMPDIR}"
  export testFile="${BATS_TEST_TMPDIR}/downloaded.file"
}

teardown() {
  unstub_all
}

function File::downloadFile::noUrl { #@test
  run File::downloadFile "" "${testFile}"
  assert_failure 1
  assert_line --index 0 --partial "URL is required"
}

function File::downloadFile::noTargetFile { #@test
  run File::downloadFile "http://example.com/file.jar" ""
  assert_failure 1
  assert_line --index 0 --partial "Target file path is required"
}

function File::downloadFile::curlSuccess { #@test
  stub curl "-fsSL -o ${testFile} http://example.com/file.jar : echo 'Downloaded' > '${testFile}'"
  command() {
    if [[ "$1" = "-v" && "$2" = "curl" ]]; then
      return 0
    fi
    builtin command "$@"
  }
  run File::downloadFile "http://example.com/file.jar" "${testFile}"
  assert_success
  [[ -f "${testFile}" ]]
  assert_equal "$(cat "${testFile}")" "Downloaded"
}

function File::downloadFile::curlFailure { #@test
  stub curl "-fsSL -o ${testFile} http://example.com/file.jar : exit 1"
  command() {
    if [[ "$1" = "-v" && "$2" = "curl" ]]; then
      return 0
    fi
    builtin command "$@"
  }
  run File::downloadFile "http://example.com/file.jar" "${testFile}"
  assert_failure 1
}

function File::downloadFile::wgetSuccess { #@test
  stub wget "-q -O ${testFile} http://example.com/file.jar : echo 'Downloaded' > '${testFile}'"
  command() {
    if [[ "$1" = "-v" && "$2" = "curl" ]]; then
      return 1
    elif [[ "$1" = "-v" && "$2" = "wget" ]]; then
      return 0
    fi
    builtin command "$@"
  }
  run File::downloadFile "http://example.com/file.jar" "${testFile}"
  assert_success
  [[ -f "${testFile}" ]]
  assert_equal "$(cat "${testFile}")" "Downloaded"
}

function File::downloadFile::wgetFailure { #@test
  stub wget "-q -O ${testFile} http://example.com/file.jar : exit 1"
  command() {
    if [[ "$1" = "-v" && "$2" = "curl" ]]; then
      return 1
    elif [[ "$1" = "-v" && "$2" = "wget" ]]; then
      return 0
    fi
    builtin command "$@"
  }
  run File::downloadFile "http://example.com/file.jar" "${testFile}"
  assert_failure 1
}

function File::downloadFile::noDownloadTools { #@test
  command() {
    if [[ "$1" = "-v" && ("$2" = "curl" || "$2" = "wget") ]]; then
      return 1
    fi
    builtin command "$@"
  }
  run File::downloadFile "http://example.com/file.jar" "${testFile}"
  assert_failure 2
  assert_line --index 0 --partial "Neither curl nor wget available"
}
