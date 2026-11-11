#!/usr/bin/env bash
# Fills in the template: asks for the metadata of the Standard and writes it into standards.yaml,
# bblocks-config.yaml and the building blocks in _sources/. Run it once, right after creating the
# repository from the template; then replace the remaining TODOs and build.
#
#   Interactive:      ./init.sh
#   Non-interactive:  STD_TITLE=… STD_DOC_NUMBER=… STD_PREFIX=… STD_BASE_URI=… STD_EDITOR=… ./init.sh
#                     (optional: STD_AFFILIATION, STD_WG) -- used by .github/workflows/initialize.yml
set -euo pipefail
cd "$(dirname "$0")"

if ! grep -q '^identifier-prefix: my\.std\.$' bblocks-config.yaml; then
  echo "This repository has already been initialized (identifier-prefix is no longer my.std.)." >&2
  exit 1
fi

# ask VAR "Question" [optional]: keeps $VAR when it is set, otherwise asks for it on a terminal
ask() {
  local var=$1 question=$2 optional=${3:-} value
  value=${!var:-}
  if [[ -z "$value" && -t 0 ]]; then
    read -r -p "$question: " value
  fi
  if [[ -z "$value" && -z "$optional" ]]; then
    echo "Missing value: $question ($var)" >&2
    exit 1
  fi
  case "$value" in
    *'"'* | *'\'*) echo "$question: double quotes and backslashes are not supported" >&2; exit 1 ;;
  esac
  printf -v "$var" '%s' "$value"
}

ask STD_TITLE       "Title of the Standard (e.g. OGC API - Example - Part 1: Core)"
ask STD_DOC_NUMBER  "OGC document number (e.g. 26-001)"
ask STD_PREFIX      "Identifier prefix of the building blocks (e.g. ogc.api.example)"
ask STD_BASE_URI    "Base URI of the requirements and conformance classes (e.g. http://www.opengis.net/spec/ogcapi-example-1/1.0)"
ask STD_EDITOR      "Editor name"
ask STD_AFFILIATION "Editor affiliation (optional)" optional
ask STD_WG          "Working group, e.g. OGC API - Example SWG (optional)" optional

STD_DOC_NUMBER=${STD_DOC_NUMBER#OGC }
STD_PREFIX=${STD_PREFIX%.}
STD_BASE_URI=${STD_BASE_URI%/}

prefix_re='^[a-z][a-z0-9-]*(\.[a-z0-9-]+)*$'
if [[ ! $STD_PREFIX =~ $prefix_re ]]; then
  echo "Invalid prefix '$STD_PREFIX': lowercase letters, digits and '-', separated by dots" >&2
  exit 1
fi
uri_re='^https?://'
if [[ ! $STD_BASE_URI =~ $uri_re ]]; then
  echo "Invalid base URI '$STD_BASE_URI': it must start with http:// or https://" >&2
  exit 1
fi

FILES=(bblocks-config.yaml standards.yaml)
while IFS= read -r f; do FILES+=("$f"); done < <(find _sources -type f)

# replace FROM TO: literal replacement in the files of the Standard
replace() {
  FROM=$1 TO=$2 perl -pi -e 's/\Q$ENV{FROM}\E/$ENV{TO}/g' "${FILES[@]}"
}

replace 'my.std.' "$STD_PREFIX."
replace 'TODO Title of the Standard' "$STD_TITLE"
replace 'YY-999' "$STD_DOC_NUMBER"
replace 'http://www.opengis.net/spec/TODO/1.0' "$STD_BASE_URI"
replace 'TODO Editor Name' "$STD_EDITOR"
if [[ -n "$STD_AFFILIATION" ]]; then replace 'TODO Editor Affiliation' "$STD_AFFILIATION"; fi
if [[ -n "$STD_WG" ]]; then replace 'TODO Working Group' "$STD_WG"; fi
replace '2026-01-01T00:00:00Z' "$(date -u +%Y-%m-%dT00:00:00Z)"
replace 'TODO 2026-01-01' "$(date -u +%Y-%m-%d)"
replace 'copyright-year: 2026' "copyright-year: $(date -u +%Y)"
replace 'Copyright © 2026' "Copyright © $(date -u +%Y)"

cat <<EOF

Initialized "$STD_TITLE" (OGC $STD_DOC_NUMBER), building blocks $STD_PREFIX.part1.*

Next steps:
  1. Replace the remaining TODOs ($(grep -rho 'TODO' standards.yaml _sources | wc -l | tr -d ' ') left):  grep -rn TODO standards.yaml _sources
  2. Generate the document:  ./build.sh  (Apple Silicon: DOCKER_DEFAULT_PLATFORM=linux/amd64 ./build.sh)
     then open build/standards/part1/index.html -- or commit and push: GitHub builds and publishes it.
EOF
