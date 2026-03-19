#!/usr/bin/env bash
set -euo pipefail

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

./scripts/generate_ocl.sh tests/fixtures/scripts/simple-deploy.sh "${tmpdir}/simple-deploy.ocl"
diff -u tests/fixtures/expected/simple-deploy.ocl "${tmpdir}/simple-deploy.ocl"

./scripts/generate_ocl.sh tests/fixtures/scripts/deploy.api.sh "${tmpdir}/deploy.api.ocl"
diff -u tests/fixtures/expected/deploy.api.ocl "${tmpdir}/deploy.api.ocl"

cp tests/fixtures/existing/custom-parameters.ocl "${tmpdir}/custom-parameters.ocl"
./scripts/generate_ocl.sh tests/fixtures/scripts/deploy-api-prod.sh "${tmpdir}/custom-parameters.ocl"
diff -u tests/fixtures/expected/custom-parameters-updated.ocl "${tmpdir}/custom-parameters.ocl"

cp tests/fixtures/existing/custom-description.ocl "${tmpdir}/custom-description.ocl"
./scripts/generate_ocl.sh tests/fixtures/scripts/deploy-api-prod.sh "${tmpdir}/custom-description.ocl"
diff -u tests/fixtures/expected/custom-description-updated.ocl "${tmpdir}/custom-description.ocl"

cp tests/fixtures/existing/custom-description.ocl "${tmpdir}/custom-description-second.ocl"
./scripts/generate_ocl.sh tests/fixtures/scripts/deploy-api-prod.sh "${tmpdir}/custom-description-second.ocl"
./scripts/generate_ocl.sh tests/fixtures/scripts/deploy-api-prod.sh "${tmpdir}/custom-description-second.ocl"
diff -u tests/fixtures/expected/custom-description-updated.ocl "${tmpdir}/custom-description-second.ocl"

cp tests/fixtures/existing/ambiguous-multiple-bash-actions.ocl "${tmpdir}/ambiguous.ocl"
if ./scripts/generate_ocl.sh tests/fixtures/scripts/deploy-api-prod.sh "${tmpdir}/ambiguous.ocl"; then
  echo "expected ambiguous existing OCL update to fail" >&2
  exit 1
fi
diff -u tests/fixtures/existing/ambiguous-multiple-bash-actions.ocl "${tmpdir}/ambiguous.ocl"
