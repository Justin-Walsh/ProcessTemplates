#!/usr/bin/env bash
set -euo pipefail

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

changed_file="${tmpdir}/changed-files.txt"
changed_file_fail="${tmpdir}/changed-files-fail.txt"
changed_file_collision="${tmpdir}/changed-files-collision.txt"
output_dir="${tmpdir}/generated"
output_dir_fail="${tmpdir}/generated-fail"
collision_repo="${tmpdir}/collision-repo"
collision_output="${tmpdir}/collision-output"

cat >"${changed_file}" <<'EOF'
deploy.api.sh
deploy-api-prod.sh
deleted-script.sh
scripts/nested.sh
EOF

mkdir -p "${output_dir}" "${output_dir_fail}"
cp tests/fixtures/existing/custom-parameters.ocl "${output_dir}/deploy-api-prod.ocl"

./scripts/sync_changed_scripts.sh "${changed_file}" "${output_dir}"

test -f "${output_dir}/deploy.api.ocl"
test -f "${output_dir}/deploy-api-prod.ocl"
test ! -e "${output_dir}/nested.ocl"

diff -u tests/fixtures/expected/deploy.api.ocl "${output_dir}/deploy.api.ocl"
diff -u tests/fixtures/expected/custom-parameters-updated.ocl "${output_dir}/deploy-api-prod.ocl"

./scripts/validate_ocl.sh "${output_dir}/deploy.api.ocl"
./scripts/validate_ocl.sh "${output_dir}/deploy-api-prod.ocl"

cat >"${changed_file_fail}" <<'EOF'
deploy-api-prod.sh
EOF

cp tests/fixtures/existing/ambiguous-multiple-bash-actions.ocl "${output_dir_fail}/deploy-api-prod.ocl"

if ./scripts/sync_changed_scripts.sh "${changed_file_fail}" "${output_dir_fail}"; then
  echo "expected sync_changed_scripts to fail for ambiguous existing OCL" >&2
  exit 1
fi

diff -u tests/fixtures/existing/ambiguous-multiple-bash-actions.ocl "${output_dir_fail}/deploy-api-prod.ocl"

mkdir -p "${collision_repo}" "${collision_output}"

cat >"${changed_file_collision}" <<'EOF'
deploy.api.sh
EOF

cat >"${collision_repo}/deploy.api.sh" <<'EOF'
#!/usr/bin/env bash
echo "dot"
EOF

cat >"${collision_repo}/deploy-api.sh" <<'EOF'
#!/usr/bin/env bash
echo "dash"
EOF

if (
  cd "${collision_repo}"
  /Users/jwalsh/Projects/ProcessTemplates/scripts/sync_changed_scripts.sh "${changed_file_collision}" "${collision_output}"
); then
  echo "expected sync_changed_scripts to fail for normalized template name collision" >&2
  exit 1
fi

test ! -e "${collision_output}/deploy.api.ocl"
