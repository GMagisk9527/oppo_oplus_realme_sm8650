#!/bin/bash
set -euo pipefail
TREE="${1:?kernel tree (common/)}"
PATCH_DIR="$(cd "$(dirname "$0")" && pwd)"
[[ -d "$TREE" ]] || { echo "f2fs_lts: missing tree $TREE" >&2; exit 1; }
shopt -s nullglob
patches=("$PATCH_DIR"/[0-9][0-9][0-9]-*.patch)
[[ ${#patches[@]} -gt 0 ]] || { echo "f2fs_lts: no patches" >&2; exit 1; }
cd "$TREE"
ok=0
for p in "${patches[@]}"; do
  base="$(basename "$p")"
  echo "f2fs_lts: apply $base"
  if git apply --whitespace=nowarn "$p" 2>/tmp/f2fs_lts.err; then
    ok=$((ok + 1))
    continue
  fi
  if patch -p1 --forward --batch --dry-run < "$p" >/tmp/f2fs_lts.dry 2>&1; then
    patch -p1 --forward --batch < "$p"
    ok=$((ok + 1))
    continue
  fi
  echo "f2fs_lts: FAILED $base" >&2
  cat /tmp/f2fs_lts.err >&2 || true
  cat /tmp/f2fs_lts.dry >&2 || true
  exit 1
done
echo "f2fs_lts: applied $ok patches"
