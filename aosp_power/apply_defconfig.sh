#!/bin/bash
# Append / fix gki_defconfig for AOSP power defaults.
set -euo pipefail
DEFCONFIG_FILE="${1:?defconfig path}"

if [[ ! -f "$DEFCONFIG_FILE" ]]; then
  echo "apply_defconfig: missing $DEFCONFIG_FILE" >&2
  exit 1
fi

# Last assignment wins for make *defconfig. Flip the OEM default-off bit.
sed -i 's/^CONFIG_RCU_LAZY_DEFAULT_OFF=y/# CONFIG_RCU_LAZY_DEFAULT_OFF is not set/' "$DEFCONFIG_FILE" || true

cat >> "$DEFCONFIG_FILE" <<'EOF'
CONFIG_RCU_NOCB_CPU=y
CONFIG_RCU_NOCB_CPU_DEFAULT_ALL=y
CONFIG_RCU_LAZY=y
# CONFIG_RCU_LAZY_DEFAULT_OFF is not set
CONFIG_WQ_POWER_EFFICIENT_DEFAULT=y
CONFIG_CPU_IDLE_GOV_TEO=y
CONFIG_LRU_GEN=y
CONFIG_LRU_GEN_ENABLED=y
EOF

echo "apply_defconfig: updated $DEFCONFIG_FILE"
