#!/usr/bin/env bash
set -euo pipefail

input_script="${1:?input script required}"
output_ocl="${2:?output path required}"

source_name="$(basename "${input_script}")"
template_name="${source_name%.sh}"
template_slug="$(printf '%s' "${template_name}" | tr '[:upper:]' '[:lower:]' | tr '.' '-')"
step_slug="$(printf '%s' "${source_name}" | tr '[:upper:]' '[:lower:]' | tr '.' '-')"

escape_script_body() {
  awk '
    {
      gsub(/\\/,"\\\\");
      gsub(/"/,"\\\"");
      printf "%s\\n", $0;
    }
  ' "${1}"
}

generate_new_ocl() {
  local script_body

  script_body="$(escape_script_body "${input_script}")"

  mkdir -p "$(dirname "${output_ocl}")"

  cat >"${output_ocl}" <<EOF
name = "${template_slug}"
description = "${template_slug} process template"

parameter "BuiltIn-TargetTag" {
    display_settings = {
        Octopus.ControlType = "TargetTags"
    }
    help_text = ""
    label = ""
}

step "${step_slug}" {
    name = "${source_name}"
    properties = {
        Octopus.Action.TargetRoles = "#{BuiltIn-TargetTag}"
    }

    action {
        action_type = "Octopus.Script"
        properties = {
            Octopus.Action.RunOnServer = "false"
            Octopus.Action.Script.ScriptBody = "${script_body}"
            Octopus.Action.Script.ScriptSource = "Inline"
            Octopus.Action.Script.Syntax = "Bash"
            OctopusUseBundledTooling = "False"
        }
        worker_pool_variable = ""
    }
}
EOF
}

update_existing_ocl() {
  local script_body replacement_info target_line indentation replacement_file temp_output

  script_body="$(escape_script_body "${input_script}")"
  replacement_info="$(
    awk '
      BEGIN {
        in_action = 0
        action_balance = 0
        candidate_count = 0
      }

      {
        line = $0

        if (!in_action && line ~ /^[[:space:]]*action[[:space:]]*\{[[:space:]]*$/) {
          in_action = 1
          action_balance = 0
          is_script = 0
          is_bash = 0
          body_count = 0
          body_line = 0
          body_prefix = ""
        }

        if (in_action) {
          if (line ~ /action_type = "Octopus\.Script"/) {
            is_script = 1
          }

          if (line ~ /Octopus\.Action\.Script\.Syntax = "Bash"/) {
            is_bash = 1
          }

          if (line ~ /^[[:space:]]*Octopus\.Action\.Script\.ScriptBody = ".*"[[:space:]]*$/) {
            body_count++
            body_line = NR
            match(line, /^[[:space:]]*/)
            body_prefix = substr(line, RSTART, RLENGTH)
          } else if (line ~ /Octopus\.Action\.Script\.ScriptBody = /) {
            body_count = 999
          }

          if (line ~ /\{[[:space:]]*$/) {
            action_balance++
          }

          if (line ~ /^[[:space:]]*}[[:space:]]*$/) {
            action_balance--

            if (action_balance == 0) {
              if (is_script && is_bash) {
                candidate_count++
                selected_body_count = body_count
                selected_body_line = body_line
                selected_body_prefix = body_prefix
              }

              in_action = 0
            }
          }
        }
      }

      END {
        if (candidate_count != 1) {
          exit 2
        }

        if (selected_body_count != 1 || selected_body_line == 0) {
          exit 3
        }

        printf "%s\t%s\n", selected_body_line, selected_body_prefix
      }
    ' "${output_ocl}"
  )" || {
    printf 'unable to locate exactly one replaceable Bash script body in %s\n' "${output_ocl}" >&2
    exit 1
  }

  target_line="${replacement_info%%	*}"
  indentation="${replacement_info#*	}"
  replacement_file="$(mktemp)"
  temp_output="$(mktemp)"
  trap 'rm -f "${replacement_file}" "${temp_output}"' RETURN

  printf '%sOctopus.Action.Script.ScriptBody = "%s"\n' "${indentation}" "${script_body}" >"${replacement_file}"

  awk -v target_line="${target_line}" -v replacement_file="${replacement_file}" '
    NR == target_line {
      getline replacement < replacement_file
      print replacement
      next
    }

    { print }
  ' "${output_ocl}" >"${temp_output}"

  mv "${temp_output}" "${output_ocl}"
}

if [ -f "${output_ocl}" ]; then
  update_existing_ocl
else
  generate_new_ocl
fi
