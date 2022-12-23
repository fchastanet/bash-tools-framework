#!/usr/bin/env bash

Filters::removeDuplicatedShebangs() {
  sed -E '1!{/^#!/d;}'
}
