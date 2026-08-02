#!/usr/bin/env bash

pmset -g batt | \
  sed -n '/[[:digit:]][[:digit:]]*%;/ { p; q; }' | \
  sed -e 's/.*(id=[[:digit:]]*)[[:space:]]*\(.*\) present: true/\1/' \
    -e 's/;//g' \
    -e 's/ discharging/ꜜ/' \
    -e 's/ remaining//' \
    -e 's/ AC attached//' \
    -e 's/ charging/ꜛ/' \
    -e 's/ finishing charge/ꜛ/' \
    -e 's/(no estimate)//' \
    -e 's/ charged 0:00//' \
    -e 's/[[:space:]][(][^)]*[)][ ]*$//'
