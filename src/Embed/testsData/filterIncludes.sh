#!/usr/bin/env bash

# INCLUDE "srcDir" As "targetDir"
# INCLUDE namespace::functions AS "myFunction"
# INCLUDE "Backup::file" as backupFile
# next line wrong "as" syntax
# INCLUDE "${ROOT_DIR}/bin/otherNeededBinary" aS "otherNeededBinary"
# INCLUDE "${BATS_TEST_DIRNAME}/test" AS targetFile0-7ù
