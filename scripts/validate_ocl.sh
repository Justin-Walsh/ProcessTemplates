#!/usr/bin/env bash
set -euo pipefail

input_ocl="${1:?input ocl required}"

fail() {
  printf '%s: %s\n' "${input_ocl}" "${1}" >&2
  exit 1
}

require_line() {
  local pattern="$1"
  local message="$2"

  if ! grep -Eq "${pattern}" "${input_ocl}"; then
    fail "${message}"
  fi
}

require_count() {
  local pattern="$1"
  local expected="$2"
  local message="$3"
  local actual

  actual="$(grep -Ec "${pattern}" "${input_ocl}")"
  if [ "${actual}" -ne "${expected}" ]; then
    fail "${message}"
  fi
}

require_line '^name = ".+"' 'missing top-level name'
require_line '^description = ".+"' 'missing top-level description'

validation_status="$(
  awk '
    BEGIN {
      in_action = 0
      action_balance = 0
      candidate_count = 0
      selected_body_count = 0
    }

    {
      line = $0

      if (!in_action && line ~ /^[[:space:]]*action[[:space:]]*\{[[:space:]]*$/) {
        in_action = 1
        action_balance = 0
        is_script = 0
        is_bash = 0
        is_inline = 0
        body_count = 0
      }

      if (in_action) {
        if (line ~ /action_type = "Octopus\.Script"/) {
          is_script = 1
        }

        if (line ~ /Octopus\.Action\.Script\.Syntax = "Bash"/) {
          is_bash = 1
        }

        if (line ~ /Octopus\.Action\.Script\.ScriptSource = "Inline"/) {
          is_inline = 1
        }

        if (line ~ /^[[:space:]]*Octopus\.Action\.Script\.ScriptBody = ".*"[[:space:]]*$/) {
          body_count++
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
              selected_inline = is_inline
              selected_body_count = body_count
            }

            in_action = 0
          }
        }
      }
    }

    END {
      if (candidate_count != 1) {
        print "expected exactly one Bash Octopus.Script action"
        exit 2
      }

      if (selected_inline != 1) {
        print "missing Octopus.Action.Script.ScriptSource = \"Inline\""
        exit 3
      }

      if (selected_body_count != 1) {
        print "expected exactly one quoted Octopus.Action.Script.ScriptBody"
        exit 4
      }
    }
  ' "${input_ocl}"
)" || fail "${validation_status}"
