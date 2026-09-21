#!/bin/bash
# Apply linux-stable QCOM/UFS/idle fixes plus 6.16/7.2 AH8/QUnipro CGC onto the OnePlus 6.1.141 OKI tree.
# Works on a git checkout or an unpacked zip (GitHub Actions).
set -euo pipefail

TREE="${1:?kernel tree (common/)}"
PATCH_DIR="$(cd "$(dirname "$0")" && pwd)"

if [[ ! -d "$TREE" ]]; then
  echo "qcom_lts: missing tree $TREE" >&2
  exit 1
fi

shopt -s nullglob
patches=("$PATCH_DIR"/[0-9][0-9][0-9]-*.patch)
if [[ ${#patches[@]} -eq 0 ]]; then
  echo "qcom_lts: no patches in $PATCH_DIR" >&2
  exit 1
fi

cd "$TREE"
ok=0
for p in "${patches[@]}"; do
  base="$(basename "$p")"
  echo "qcom_lts: apply $base"
  if git apply --whitespace=nowarn "$p" 2>/tmp/qcom_lts.err; then
    ok=$((ok + 1))
    continue
  fi
  if patch -p1 --forward --batch --dry-run < "$p" >/tmp/qcom_lts.dry 2>&1; then
    patch -p1 --forward --batch < "$p"
    ok=$((ok + 1))
    continue
  fi
  echo "qcom_lts: FAILED $base" >&2
  cat /tmp/qcom_lts.err >&2 || true
  cat /tmp/qcom_lts.dry >&2 || true
  exit 1
done
echo "qcom_lts: applied $ok patches"
