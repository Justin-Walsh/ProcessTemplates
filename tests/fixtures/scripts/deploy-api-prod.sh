#!/usr/bin/env bash

set -euo pipefail

echo 'Starting prod deploy'

printf 'path=%s\n' "/srv/apps/current"
printf 'literal-backslash=%s\n' "\\"
printf 'quoted=%s\n' "\"double\" and 'single'"

if [ -n "${REGION:-}" ]; then
 echo "Region: ${REGION}"
fi

cat <<'EOF'
keep #{BuiltIn.Environment.Name} literal
keep $(hostname) literal in source until runtime
EOF
