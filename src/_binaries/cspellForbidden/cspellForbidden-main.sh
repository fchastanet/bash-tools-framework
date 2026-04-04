#!/usr/bin/env bash

# ensure .cspell/forbidden.txt exists
if [[ ! -f ".cspell/forbidden.txt" ]]; then
  mkdir -p .cspell
  Log::fatal "The file .cspell/forbidden.txt does not exist. Please create it or link it and add the forbidden words, one per line with !word."
fi

# ensure .cspell/forbidden.txt is used by cspell
# Determine which config file to use (prefer yaml over json)
cspellConfigFile="cspell.json"
if [[ -f "cspell.yaml" ]]; then
  cspellConfigFile="cspell.yaml"
elif [[ -f "cspell.yml" ]]; then
  cspellConfigFile="cspell.yml"
elif [[ ! -f "cspell.json" ]]; then
  # If no config file exists, create cspell.json
  echo '{}' >cspell.json
  cspellConfigFile="cspell.json"
fi

# Update the config file with forbidden dictionary configuration
# Use jq for processing, converting YAML to JSON if needed
read -r -d '' JQ_SCRIPT <<'EOF' || true
.ignorePaths //= [] |
.ignorePaths |= if index(".cspell/forbidden.txt") then . else . + [".cspell/forbidden.txt"] end |
.dictionaryDefinitions //= [] |
.dictionaryDefinitions |= if any(.name == "forbidden") then
  map(if .name == "forbidden" then . + {addWords: false, path: ".cspell/forbidden.txt"} else . end)
else
  . + [{name: "forbidden", addWords: false, path: ".cspell/forbidden.txt"}]
end |
.dictionaries //= [] |
.dictionaries |= if index("forbidden") then . else . + ["forbidden"] end |
.dictionaries |= unique |
.version //= "0.2" |
.language //= "en" |
.noConfigSearch //= true |
.caseSensitive //= true |
.useGitignore //= true |
.enableGlobDot //= true |
.enableFiletypes //= [] |
.enableFiletypes |= if index("shellscript") then . else . + ["shellscript"] end
EOF

if [[ "${cspellConfigFile}" == *.json ]]; then
  # JSON format: update directly
  jq "${JQ_SCRIPT}" "${cspellConfigFile}" >"${TMPDIR}/tmp.$$.json" || {
    Log::fatal "Failed to update ${cspellConfigFile} with forbidden dictionary configuration using jq script"
  }
  mv "${TMPDIR}/tmp.$$.json" "${cspellConfigFile}"
else
  # YAML format: convert to JSON, update, convert back to YAML
  yq -o json "${cspellConfigFile}" | jq "${JQ_SCRIPT}" | yq -P >"${TMPDIR}/tmp.$$.yaml" || {
    Log::fatal "Failed to update ${cspellConfigFile} with forbidden dictionary configuration using jq/yq script"
  }
  cat "${TMPDIR}/tmp.$$.yaml"
  mv "${TMPDIR}/tmp.$$.yaml" "${cspellConfigFile}"
fi

# ensure .cspell/forbidden.txt is ignored by git
if ! git check-ignore -q .cspell/forbidden.txt; then
  if ! grep -q "^.cspell/forbidden.txt$" .gitignore 2>/dev/null; then
    echo ".cspell/forbidden.txt" >>.gitignore
  fi
fi

# check that all words from .cspell/forbidden.txt are beginning with "!" (except for empty lines and comments)
if grep -E '^[^#!]' .cspell/forbidden.txt >/dev/null; then
  Log::fatal "All words in .cspell/forbidden.txt must start with '!' (except for empty lines and comments). Please update the file accordingly."
fi

# run cspell on git tracked files
# shellcheck disable=SC2154
(
  git ls-files
  git ls-tree --full-tree -r --name-only HEAD
) | sort | uniq |
  npx cspell --quiet --no-must-find-files --file-list stdin "${cspellOptions[@]}"
