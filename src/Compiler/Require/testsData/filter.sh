#!/usr/bin/env bash

# @require "Namespace::requireSomething"
# @require Namespace::requireSomething
# next is invalid but filterable
# @require "${BATS_TEST_DIRNAME}/test
# next is invalid but filterable
# @require EST_DIRNAME}/test"
# next is invalid
#@require "${FRAMEWORK_ROOT_DIR}/bin/otherNeededBinary"
# next is invalid
# @require"${FRAMEWORK_ROOT_DIR}/bin/otherNeededBinary"
# next is invalid
# @require
