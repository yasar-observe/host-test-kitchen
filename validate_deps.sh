#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

declare -A DEPS

DEPS=( [ruby]='3.2.2'
       [terraform]='v1.5.4'
       [aws]='2.13.10'
       [bundler]='2.2.3'
)

for dep in "${!DEPS[@]}"; do
  printf "checking for %s version %s..." "$dep" "${DEPS[$dep]}"
  (command -v "$dep">/dev/null) || printf "\n\tUnable to find %s...\n" "$dep"
  _version="$($dep --version)"
  [[ "$_version" =~ "${DEPS[$dep]}" ]] || printf "\n\t%s installed but version is %s...\n" "$dep" "$_version"
  printf "Done.\n"
done
