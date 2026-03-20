#!/usr/bin/bash

set -eoux pipefail

BUILD_SCRIPTS_PATH="$(realpath "$(dirname "$0")")"

# Find all scripts in the build directory that start with two digits and a hyphen
find "${BUILD_SCRIPTS_PATH}" -maxdepth 1 -name "[0-9][0-9]-*.sh" -type f -print0 | sort --zero-terminated -V | while IFS= read -r -d $'\0' script ; do
    printf "::group:: ===%s===\n" "$(basename "$script")"
    bash "$script"
    printf "::endgroup::\n"
done