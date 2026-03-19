#!/usr/bin/env bash
set -euo pipefail

grep -E '^[^/]+\.sh$' | sort -u
