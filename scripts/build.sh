#!/usr/bin/env bash
set -euo pipefail

src="project"
dst="dist"
name="forgotten-maps"

function godot-export() {
    mkdir -p "${dst}/${1}"
    godot --path "${src}" --export-release "${1}" --headless
}

function godot-bundle() {
    pushd "dist/${1}"
    zip "${name}.zip" "${name}.${2}" "${name}.pck"
    popd
}

godot-export linux && godot-bundle linux x86_64
godot-export windows && godot-bundle windows exe
godot-export mac
