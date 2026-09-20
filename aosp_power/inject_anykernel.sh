#!/bin/bash
# Patch AnyKernel3: boot cmdline + optional KSU/Magisk helper module.
set -euo pipefail

AK_DIR="${1:?AnyKernel3 directory}"
SRC_DIR="$(cd "$(dirname "$0")" && pwd)"

AK_SH="$AK_DIR/anykernel.sh"
if [[ ! -f "$AK_SH" ]]; then
  echo "inject_anykernel: missing $AK_SH" >&2
  exit 1
fi

python3 - "$AK_SH" <<'PY'
import pathlib, sys, re

p = pathlib.Path(sys.argv[1])
t = p.read_text()

if 'patch_cmdline "rcutree.enable_rcu_lazy"' in t:
    print("inject_anykernel: cmdline already patched")
else:
    m = re.search(r"(?m)^split_boot\s*$", t)
    if not m:
        raise SystemExit("anykernel.sh: split_boot not found")
    insert = (
        "\n# AOSP power defaults (RCU Lazy / power-efficient WQ / TEO / schedstats)\n"
        'ui_print "Applying AOSP power cmdline..."\n'
        'patch_cmdline "rcutree.enable_rcu_lazy" "rcutree.enable_rcu_lazy=1"\n'
        'patch_cmdline "rcu_nocbs" "rcu_nocbs=all"\n'
        'patch_cmdline "workqueue.power_efficient" "workqueue.power_efficient=1"\n'
        'patch_cmdline "cpuidle.governor" "cpuidle.governor=teo"\n'
        'patch_cmdline "schedstats" "schedstats=disable"\n'
    )
    t = t[: m.end()] + insert + t[m.end() :]
    print("inject_anykernel: inserted cmdline patches")

if "$AKHOME/aosp_power.zip" in t:
    print("inject_anykernel: module install already patched")
else:
    extra = '''
if [ -f "$AKHOME/aosp_power.zip" ]; then
    MODULE_PATH="$AKHOME/aosp_power.zip"
    KSUD_PATH="/data/adb/ksud"
    MAGISK_PATH="/data/adb/magisk"
    if [ -f "$KSUD_PATH" ]; then
        ui_print "Installing aosp_power module (KSU)..."
        /data/adb/ksud module install "$MODULE_PATH"
        ui_print "aosp_power installed."
    elif [ -d "$MAGISK_PATH" ] && command -v magisk >/dev/null 2>&1; then
        ui_print "Installing aosp_power module (Magisk)..."
        magisk --install-module "$MODULE_PATH"
        ui_print "aosp_power installed."
    else
        ui_print "No KSU/Magisk, aosp_power module skipped (cmdline still applied)."
    fi
else
    ui_print "aosp_power module not in zip, skipping..."
fi
'''
    m = re.search(
        r'ui_print "ZRAM module Not Found, skipping ZRAM module installation\.\.\."\nfi\n',
        t,
    )
    if not m:
        raise SystemExit("anykernel.sh: zram skip block not found")
    t = t[: m.end()] + extra + t[m.end() :]
    print("inject_anykernel: inserted aosp_power module install")

p.write_text(t)
print("inject_anykernel: wrote", p)
PY

MOD_DIR="$SRC_DIR/module"
if [[ ! -f "$MOD_DIR/module.prop" || ! -f "$MOD_DIR/service.sh" ]]; then
  echo "inject_anykernel: missing module files" >&2
  exit 1
fi
chmod 755 "$MOD_DIR/service.sh"
rm -f "$AK_DIR/aosp_power.zip"
(
  cd "$MOD_DIR"
  zip -q -9 -r "$AK_DIR/aosp_power.zip" module.prop service.sh META-INF
)
echo "inject_anykernel: wrote $AK_DIR/aosp_power.zip"
