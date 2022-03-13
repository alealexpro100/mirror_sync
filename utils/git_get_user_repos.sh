#!/bin/bash

if [[ -n $1 ]]; then
  echo "No user!"
  exit 1
fi

while read -r var; do
  var=${var//\"/}
  echo "$var.git ${var//https\:\/\//}"
done < <(curl "https://api.github.com/users/$1/repos" | jq '.[]|.html_url')
