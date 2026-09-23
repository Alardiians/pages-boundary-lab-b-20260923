#!/usr/bin/env bash
set -euo pipefail
printf 'EXECUTION_MARKER=DOT_ARTIFACT_SAFE_PATH_CONTROL\n'
observed="$(printf '%s' "${DOT_DUMMY_SECRET:-}" | sha256sum | cut -d' ' -f1)"
mkdir -p proof
if [ "$observed" = 'cadd51adf2099cdc3609ebc64bb594d912cee9c32d39aaafccfee6d906d660f6' ]; then
  printf 'RECEIVER_MARKER=PR_DOT_PAYLOAD\nDUMMY_SECRET_MATCH=true\n' > proof/receiver-boolean.txt
else
  printf 'RECEIVER_MARKER=PR_DOT_PAYLOAD\nDUMMY_SECRET_MATCH=false\n' > proof/receiver-boolean.txt
fi
