#!/bin/sh
printf '\033c\033]0;%s\a' Laboratorio
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Laboratorio.x86_64" "$@"
