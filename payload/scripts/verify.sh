#!/usr/bin/env bash
set -euo pipefail
printf 'EXECUTION_MARKER=DOT_ARTIFACT\n'
observed="$(printf '%s' "${DOT_DUMMY_SECRET:-}" | sha256sum | cut -d' ' -f1)"
if [ "$observed" = 'cadd51adf2099cdc3609ebc64bb594d912cee9c32d39aaafccfee6d906d660f6' ]; then
  printf 'DUMMY_SECRET_MATCH=true\n'
else
  printf 'DUMMY_SECRET_MATCH=false\n'
fi
