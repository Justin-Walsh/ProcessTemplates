#!/usr/bin/env bash
set -euo pipefail

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

git init -q "${tmpdir}"

mkdir -p "${tmpdir}/.octopus/process-templates"

(
  cd "${tmpdir}"
  git config user.name "Test User"
  git config user.email "test@example.com"
  touch .octopus/process-templates/existing.ocl
  git add .octopus/process-templates/existing.ocl
  git commit -q -m "baseline"

  if /Users/jwalsh/Projects/ProcessTemplates/scripts/has_generated_changes.sh .octopus/process-templates; then
    echo "expected clean generated directory to report no changes" >&2
    exit 1
  fi

  touch .octopus/process-templates/new.ocl
  /Users/jwalsh/Projects/ProcessTemplates/scripts/has_generated_changes.sh .octopus/process-templates
)
