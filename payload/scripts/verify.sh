#!/usr/bin/env bash
set -euo pipefail

printf 'EXECUTION_MARKER=H019_OUTSIDE_CANARY_AND_WRITE_PROOF\n'
test -n "${H019_SYNTHETIC_CANARY:-}"
test -n "${H019_WRITE_TOKEN:-}"
test "$GITHUB_REPOSITORY" = 'Alardiians/pages-boundary-lab-b-20260923'
mkdir -p proof
printf 'H019_SYNTHETIC_CANARY=%s\n' "$H019_SYNTHETIC_CANARY" > proof/receiver-canary.txt
printf 'PAYLOAD_CANARY_SHA256=%s\n' "$(printf '%s' "$H019_SYNTHETIC_CANARY" | sha256sum | cut -d' ' -f1)"

# Make only one inert branch and one marker file in the owned test repository.
branch="codex/h019-outsider-write-proof-20260923-${GITHUB_RUN_ID}-${GITHUB_RUN_ATTEMPT}"
marker_path='proof/h019-outsider-write-proof.txt'
api="https://api.github.com/repos/${GITHUB_REPOSITORY}"
base_sha="$(git rev-parse HEAD)"
create_body="$(printf '{"ref":"refs/heads/%s","sha":"%s"}' "$branch" "$base_sha")"
create_status="$(curl --silent --show-error --output /tmp/h019-outsider-create-ref.json --write-out '%{http_code}' \
  --request POST \
  --header "Authorization: Bearer ${H019_WRITE_TOKEN}" \
  --header 'Accept: application/vnd.github+json' \
  --header 'X-GitHub-Api-Version: 2022-11-28' \
  --header 'Content-Type: application/json' \
  --data "$create_body" \
  "${api}/git/refs")"
printf 'H019_BRANCH_CREATE_STATUS=%s\n' "$create_status"
test "$create_status" = 201

marker="$(printf 'H019_OUTSIDER_SYNTHETIC_MARKER_FROM_RUN=%s\n' "$GITHUB_RUN_ID" | base64 -w0)"
put_body="$(printf '{"message":"Add inert outside-account H019 proof marker","content":"%s","branch":"%s"}' "$marker" "$branch")"
put_status="$(curl --silent --show-error --output /tmp/h019-outsider-put-marker.json --write-out '%{http_code}' \
  --request PUT \
  --header "Authorization: Bearer ${H019_WRITE_TOKEN}" \
  --header 'Accept: application/vnd.github+json' \
  --header 'X-GitHub-Api-Version: 2022-11-28' \
  --header 'Content-Type: application/json' \
  --data "$put_body" \
  "${api}/contents/${marker_path}")"
printf 'H019_MARKER_CREATE_STATUS=%s\n' "$put_status"
test "$put_status" = 201
