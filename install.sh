#!/usr/bin/env bash

mydir=$(dirname "$(realpath "$0")")

# This is the local directory where bash completion may look:
dir=${BASH_COMPLETION_USER_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/bash-completion}/completions

mkdir -p "$dir"
echo "Copying to '$dir/'"
# Files must be named "command.bash" or "command"
cp --remove-destination -p "${mydir}"/*.bash "$dir/"
