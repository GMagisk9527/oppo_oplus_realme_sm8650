#!/bin/bash
set -euo pipefail
TREE="${1:?kernel tree (common/)}"
PATCH_DIR="$(cd "$(dirname "$0")" && pwd)"
[[ -d "$TREE" ]] || { echo "aosp_psi: missing tree $TREE" >&2; exit 1; }
shopt -s nullglob
patches=("$PATCH_DIR"/[0-9][0-9][0-9]-*.patch)
[[ ${#patches[@]} -gt 0 ]] || { echo "aosp_psi: no patches" >&2; exit 1; }
cd "$TREE"
ok=0
for p in "${patches[@]}"; do
  base="$(basename "$p")"
  echo "aosp_psi: apply $base"
  if git apply --whitespace=nowarn "$p" 2>/tmp/aosp_psi.err; then
    ok=$((ok + 1))
    continue
  fi
  if patch -p1 --forward --batch --dry-run < "$p" >/tmp/aosp_psi.dry 2>&1; then
    patch -p1 --forward --batch < "$p"
    ok=$((ok + 1))
    continue
  fi
  echo "aosp_psi: FAILED $base" >&2
  cat /tmp/aosp_psi.err >&2 || true
  cat /tmp/aosp_psi.dry >&2 || true
  exit 1
done
echo "aosp_psi: applied $ok patches"
