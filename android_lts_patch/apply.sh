#!/bin/bash
set -euo pipefail
TREE="${1:?kernel tree (common/)}"
PATCH_DIR="$(cd "$(dirname "$0")" && pwd)"
[[ -d "$TREE" ]] || { echo "android_lts: missing tree $TREE" >&2; exit 1; }
shopt -s nullglob
patches=("$PATCH_DIR"/[0-9][0-9][0-9]-*.patch)
[[ ${#patches[@]} -gt 0 ]] || { echo "android_lts: no patches" >&2; exit 1; }
cd "$TREE"
ok=0
for p in "${patches[@]}"; do
  base="$(basename "$p")"
  echo "android_lts: apply $base"
  if git apply --whitespace=nowarn "$p" 2>/tmp/android_lts.err; then
    ok=$((ok + 1))
    continue
  fi
  if patch -p1 --forward --batch --dry-run < "$p" >/tmp/android_lts.dry 2>&1; then
    patch -p1 --forward --batch < "$p"
    ok=$((ok + 1))
    continue
  fi
  echo "android_lts: FAILED $base" >&2
  cat /tmp/android_lts.err >&2 || true
  cat /tmp/android_lts.dry >&2 || true
  exit 1
done
echo "android_lts: applied $ok patches"
