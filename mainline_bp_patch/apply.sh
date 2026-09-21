#!/bin/bash
# Apply independent mainline 6.6–6.18 backports onto the OnePlus 6.1.141 OKI tree.
set -euo pipefail

TREE="${1:?kernel tree (common/)}"
PATCH_DIR="$(cd "$(dirname "$0")" && pwd)"

if [[ ! -d "$TREE" ]]; then
  echo "mainline_bp: missing tree $TREE" >&2
  exit 1
fi

shopt -s nullglob
patches=("$PATCH_DIR"/[0-9][0-9][0-9]-*.patch)
if [[ ${#patches[@]} -eq 0 ]]; then
  echo "mainline_bp: no patches in $PATCH_DIR" >&2
  exit 1
fi

cd "$TREE"
ok=0
for p in "${patches[@]}"; do
  base="$(basename "$p")"
  echo "mainline_bp: apply $base"
  if git apply --whitespace=nowarn "$p" 2>/tmp/mainline_bp.err; then
    ok=$((ok + 1))
    continue
  fi
  if patch -p1 --forward --batch --dry-run < "$p" >/tmp/mainline_bp.dry 2>&1; then
    patch -p1 --forward --batch < "$p"
    ok=$((ok + 1))
    continue
  fi
  echo "mainline_bp: FAILED $base" >&2
  cat /tmp/mainline_bp.err >&2 || true
  cat /tmp/mainline_bp.dry >&2 || true
  exit 1
done
echo "mainline_bp: applied $ok patches"
