#!/bin/bash

set -e

mirror_dir="mikrotik"
download_archive=0

function get_actual_url() {
  curl --silent --location --head --output /dev/null --write-out '%{url_effective}' -- "$@"
  echo
}

function url_parse_list() {
  while IFS=$'\n' read -r line; do
    if [[ $line =~ href\=\"(https:\/\/download.mikrotik.com\/[a-zA-Z0-9\/._-]+)\" ]]; then
      echo "${BASH_REMATCH[1]}"
    fi
  done
}

function get_files() {
  get_actual_url "https://mt.lv/winbox"
  get_actual_url "https://mt.lv/winbox64"
  curl "https://mikrotik.com/download" | url_parse_list
  if [[ "$download_archive" == "1" ]]; then
    curl "https://mikrotik.com/download/archive" | url_parse_list
  fi
}

function download_files() (
  [[ -d "$mirror_dir" ]] || mkdir -p "$mirror_dir"
  cd "$mirror_dir"
  get_files | sort -u > "urls_list"
  while read -r line; do
    file="${line//https\:\/\//}"
    if [[ ! -f "$file" ]]; then
      dir="${file%/*}"
      [[ -d "$dir" ]] || mkdir -p "$dir"
      [[ -f "$file.tmp" ]] && rm -rf "$file.tmp"
      wget -O "$file.tmp" "$line"
      mv "$file.tmp" "$file"
    fi
  done < <(cat "urls_list")
)

download_files
