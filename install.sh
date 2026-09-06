#!/usr/bin/env bash
# Install (or refresh) mpd.menu into the running Omarchy shell.
# For development: rsync this tree into the plugins dir, validate, enable.
# QML code changes need the shell restarted to load (see note below).
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
plugins_dir="$HOME/.config/omarchy/plugins"
target="$plugins_dir/mpd.menu"

omarchy plugin validate "$repo_dir"

mkdir -p "$plugins_dir"
if [[ -d $target && ! -L $target ]]; then
  rm -rf "$target"
fi
mkdir -p "$target"
rsync -a --delete --exclude .git --exclude install.sh "$repo_dir/" "$target/"

omarchy-shell shell rescanPlugins >/dev/null
omarchy plugin enable mpd.menu >/dev/null
echo "mpd.menu installed at $target and enabled"
echo "note: QML code changes need \`omarchy restart shell\` to take effect"
# Summons: omarchy-shell shell toggle mpd.menu '{"menu":"root"}'
