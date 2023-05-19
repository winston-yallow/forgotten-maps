#!/usr/bin/env bash
set -euo pipefail

user="winston-yallow"
name="forgotten-maps"
versionfile="version.txt"

function butler-upload() {
    butler \
        push \
        "dist/${1}/${name}.zip" \
        "${user}/${name}:${1}" \
        --userversion-file "${versionfile}"
}

butler-upload linux
butler-upload windows
butler-upload mac
