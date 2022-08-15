#!/usr/bin/env bash

uptime | cut -d "," -f 3- | cut -d ":" -f2 | sed -e "s/^[ \t]*//" | cut -d " " -f1
