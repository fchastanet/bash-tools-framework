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
sed -i -E '0,/fail_fast: true/s//fail_fast: false/' .pre-commit-config-github.yaml
