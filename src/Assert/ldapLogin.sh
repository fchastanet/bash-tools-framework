#!/usr/bin/env bash

# @description check if argument respects ldap login naming convention
# only using  smallcase characters a-z
# @arg $1 ldapLogin:String
# @exitcode 1 if regexp not matches
Assert::ldapLogin() {
  [[ $1 =~ ^[a-z]+$ ]]
}
