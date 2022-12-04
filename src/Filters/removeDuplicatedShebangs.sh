#!/usr/bin/env bash

Filters::removeDuplicatedShebangs() {
  sed '1!{/^#!/d;}'
}
