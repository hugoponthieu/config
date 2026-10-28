#!/bin/sh

set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_packages=$(mktemp)
aur_packages=$(mktemp)

cleanup() {
  rm -f -- "$repo_packages" "$aur_packages"
}
trap cleanup EXIT HUP INT TERM

{
  pacman -Qqen
  printf '%s\n' chezmoi
} | LC_ALL=C sort -u > "$repo_packages"

pacman -Qqem | sed '/-debug$/d' | LC_ALL=C sort -u > "$aur_packages"

install -m0644 "$repo_packages" "$script_dir/.chezmoitemplates/packages-repo.txt"
install -m0644 "$aur_packages" "$script_dir/.chezmoitemplates/packages-aur.txt"

printf 'Paquets synchronisés : %s officiels, %s AUR/locaux.\n' \
  "$(wc -l < "$repo_packages")" \
  "$(wc -l < "$aur_packages")"
