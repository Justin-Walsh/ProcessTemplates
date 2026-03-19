#!/usr/bin/env bash
set -euo pipefail

./scripts/validate_ocl.sh tests/fixtures/expected/simple-deploy.ocl
./scripts/validate_ocl.sh tests/fixtures/expected/deploy.api.ocl
./scripts/validate_ocl.sh tests/fixtures/expected/custom-parameters-updated.ocl
./scripts/validate_ocl.sh tests/fixtures/expected/custom-description-updated.ocl

if ./scripts/validate_ocl.sh tests/fixtures/invalid/missing-script-body.ocl; then
  echo "expected missing-script-body fixture to fail" >&2
  exit 1
fi

if ./scripts/validate_ocl.sh tests/fixtures/invalid/non-bash-script.ocl; then
  echo "expected non-bash-script fixture to fail" >&2
  exit 1
fi

if ./scripts/validate_ocl.sh tests/fixtures/invalid/ambiguous-multiple-bash-actions.ocl; then
  echo "expected ambiguous-multiple-bash-actions fixture to fail" >&2
  exit 1
fi
