#!/bin/bash
set -euo pipefail
TREE="${1:?kernel tree (common/)}"
PATCH_DIR="$(cd "$(dirname "$0")" && pwd)"
[[ -d "$TREE" ]] || { echo "ack_backport: missing tree $TREE" >&2; exit 1; }
shopt -s nullglob
patches=("$PATCH_DIR"/[0-9][0-9][0-9]-*.patch)
[[ ${#patches[@]} -gt 0 ]] || { echo "ack_backport: no patches" >&2; exit 1; }
cd "$TREE"
ok=0
for p in "${patches[@]}"; do
  base="$(basename "$p")"
  echo "ack_backport: apply $base"
  if git apply --whitespace=nowarn "$p" 2>/tmp/ack_backport.err; then
    ok=$((ok + 1))
    continue
  fi
  if patch -p1 --forward --batch --dry-run < "$p" >/tmp/ack_backport.dry 2>&1; then
    patch -p1 --forward --batch < "$p"
    ok=$((ok + 1))
    continue
  fi
  echo "ack_backport: FAILED $base" >&2
  cat /tmp/ack_backport.err >&2 || true
  cat /tmp/ack_backport.dry >&2 || true
  exit 1
done
echo "ack_backport: applied $ok patches"
