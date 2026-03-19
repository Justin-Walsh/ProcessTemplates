#!/usr/bin/env bash
set -euo pipefail

changed_files_input="${1:?changed files input required}"
output_dir="${2:?output directory required}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

while IFS= read -r source_script; do
  if [ ! -f "${source_script}" ]; then
    continue
  fi

  target_ocl="${output_dir}/$(basename "${source_script%.sh}").ocl"

  if ! "${script_dir}/generate_ocl.sh" "${source_script}" "${target_ocl}"; then
    printf 'failed to generate OCL for %s -> %s\n' "${source_script}" "${target_ocl}" >&2
    exit 1
  fi

  if ! "${script_dir}/validate_ocl.sh" "${target_ocl}"; then
    printf 'failed to validate OCL for %s -> %s\n' "${source_script}" "${target_ocl}" >&2
    exit 1
  fi
done < <("${script_dir}/list_changed_scripts.sh" <"${changed_files_input}")
