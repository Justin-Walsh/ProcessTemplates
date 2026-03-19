#!/usr/bin/env bash
set -euo pipefail

expected_file="$(mktemp)"
actual_file="$(mktemp)"
trap 'rm -f "${expected_file}" "${actual_file}"' EXIT

cat >"${expected_file}" <<'EOF'
deploy-api-prod.sh
deploy.api.sh
EOF

printf '%s\n' deploy.api.sh deploy-api-prod.sh scripts/nested.sh deploy.ps1 README.md '' deploy.api.sh \
  | ./scripts/list_changed_scripts.sh >"${actual_file}"

diff -u "${expected_file}" "${actual_file}"
