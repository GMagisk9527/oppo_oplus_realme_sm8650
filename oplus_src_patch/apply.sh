#!/bin/bash
# Apply OnePlus 6.1.141 OKI hot-path cleanups (vendor debug compiled into daily paths).
set -euo pipefail

TREE="${1:?kernel tree (common/)}"
PATCH_DIR="$(cd "$(dirname "$0")" && pwd)"

if [[ ! -d "$TREE" ]]; then
  echo "oplus_src: missing tree $TREE" >&2
  exit 1
fi

shopt -s nullglob
patches=("$PATCH_DIR"/[0-9][0-9][0-9]-*.patch)
if [[ ${#patches[@]} -eq 0 ]]; then
  echo "oplus_src: no patches in $PATCH_DIR" >&2
  exit 1
fi

cd "$TREE"
ok=0
for p in "${patches[@]}"; do
  base="$(basename "$p")"
  echo "oplus_src: apply $base"
  if git apply --whitespace=nowarn "$p" 2>/tmp/oplus_src.err; then
    ok=$((ok + 1))
    continue
  fi
  if patch -p1 --forward --batch --dry-run < "$p" >/tmp/oplus_src.dry 2>&1; then
    patch -p1 --forward --batch < "$p"
    ok=$((ok + 1))
    continue
  fi
  echo "oplus_src: FAILED $base" >&2
  cat /tmp/oplus_src.err >&2 || true
  cat /tmp/oplus_src.dry >&2 || true
  exit 1
done
echo "oplus_src: applied $ok patches"
