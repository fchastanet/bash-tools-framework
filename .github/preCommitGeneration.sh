#!/bin/bash

awk \
  '''
    1;/---/{
      print "###############################################################################"
      print "# AUTOMATICALLY GENERATED"
      print "# DO NOT EDIT IT"
      print "# @generated"
      print "###############################################################################"
    }
  ''' .pre-commit-config.yaml >.pre-commit-config-github.yaml
sed -i -E \
  -e '0,/fail_fast: true/s//fail_fast: false/' \
  -e 's/stages: \[\] # GITHUB/stages: \[manual\] # GITHUB/' \
  -e 's/--format, plain, /--format, checkstyle, /g' \
  -e 's/shellcheckLint/shellcheckLintGithubAction/g' \
  .pre-commit-config-github.yaml
