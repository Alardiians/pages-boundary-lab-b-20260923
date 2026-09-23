#!/usr/bin/env bash
set -euo pipefail

printf 'EXECUTION_MARKER=DOT_ARTIFACT_V3_WRITE_TEST\n'
observed="$(printf '%s' "${DOT_DUMMY_SECRET:-}" | sha256sum | cut -d' ' -f1)"
mkdir -p proof
if [ "$observed" = 'cadd51adf2099cdc3609ebc64bb594d912cee9c32d39aaafccfee6d906d660f6' ]; then
  printf 'RECEIVER_MARKER=PR_DOT_PAYLOAD\nDUMMY_SECRET_MATCH=true\n' > proof/receiver-boolean.txt
else
  printf 'RECEIVER_MARKER=PR_DOT_PAYLOAD\nDUMMY_SECRET_MATCH=false\n' > proof/receiver-boolean.txt
fi

# The only remote change is an inert marker on a new disposable branch in this owned repo.
# curl writes API response bodies to temporary files, never to the run log.
branch='codex/h019-dot-write-proof-20260923'
marker_path='proof/h019-dot-write-proof.txt'
api="https://api.github.com/repos/${GITHUB_REPOSITORY}"
base_sha="$(git rev-parse HEAD)"
create_body="$(printf '{"ref":"refs/heads/%s","sha":"%s"}' "$branch" "$base_sha")"
create_status="$(curl --silent --show-error --output /tmp/h019-create-ref.json --write-out '%{http_code}' \
  --request POST \
  --header "Authorization: Bearer ${H019_WRITE_TOKEN}" \
  --header 'Accept: application/vnd.github+json' \
  --header 'X-GitHub-Api-Version: 2022-11-28' \
  --header 'Content-Type: application/json' \
  --data "$create_body" \
  "${api}/git/refs")"
printf 'H019_BRANCH_CREATE_STATUS=%s\n' "$create_status"
test "$create_status" = 201

marker="$(printf 'H019_SYNTHETIC_MARKER_FROM_RUN=%s\n' "$GITHUB_RUN_ID" | base64 -w0)"
put_body="$(printf '{"message":"Add inert H019 proof marker","content":"%s","branch":"%s"}' "$marker" "$branch")"
put_status="$(curl --silent --show-error --output /tmp/h019-put-marker.json --write-out '%{http_code}' \
  --request PUT \
  --header "Authorization: Bearer ${H019_WRITE_TOKEN}" \
  --header 'Accept: application/vnd.github+json' \
  --header 'X-GitHub-Api-Version: 2022-11-28' \
  --header 'Content-Type: application/json' \
  --data "$put_body" \
  "${api}/contents/${marker_path}")"
printf 'H019_MARKER_CREATE_STATUS=%s\n' "$put_status"
test "$put_status" = 201
