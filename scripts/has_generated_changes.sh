#!/usr/bin/env bash
set -euo pipefail

target_path="${1:?target path required}"

git status --porcelain -- "${target_path}" | grep -q .
