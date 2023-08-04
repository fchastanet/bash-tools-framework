#!/usr/bin/env bash

# EMBED "srcDir" As "targetDir"
# EMBED namespace::functions AS "myFunction"
# EMBED "Backup::file" as backupFile
# next line wrong "as" syntax
# EMBED "${ROOT_DIR}/bin/otherNeededBinary" aS "otherNeededBinary"
# EMBED "${BATS_TEST_DIRNAME}/test" AS targetFile0-7ù
