#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
repo_name="$(basename "$repo_root")"
src="$repo_root/cs2"
dst="$(cd "$repo_root/.." && pwd)"
backup="$dst/cfg-backup-$(date +%Y%m%d-%H%M%S)"

[ -d "$src" ] || { echo "missing $src" >&2; exit 1; }

for path in "$src"/*; do
    name="$(basename "$path")"
    target="$dst/$name"

    if [ -L "$target" ]; then
        rm "$target"
    elif [ -e "$target" ]; then
        mkdir -p "$backup"
        mv "$target" "$backup/"
        echo "backed up  $name"
    fi

    ln -s "$repo_name/cs2/$name" "$target"
    echo "linked     $name to $repo_name/cs2/$name"
done

if [ -d "$backup" ]; then
    echo
    echo "backup: $backup"
fi
