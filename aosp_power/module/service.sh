#!/system/bin/sh
# Late start: OEM userspace may reset cpuidle / vm knobs after boot.

log() {
  echo "aosp_power: $*" | tee /dev/kmsg >/dev/null 2>&1 || true
}

# 2) scheduler statistics — small extra cost in the scheduler hot path
if [ -w /proc/sys/kernel/sched_schedstats ]; then
  echo 0 >/proc/sys/kernel/sched_schedstats
  log "sched_schedstats=$(cat /proc/sys/kernel/sched_schedstats 2>/dev/null)"
fi

# 4) MGLRU — already CONFIG_LRU_GEN_ENABLED=y; pin it if init turned it off
if [ -w /sys/kernel/mm/lru_gen/enabled ]; then
  echo y >/sys/kernel/mm/lru_gen/enabled 2>/dev/null \
    || echo 7 >/sys/kernel/mm/lru_gen/enabled 2>/dev/null \
    || true
  log "lru_gen=$(cat /sys/kernel/mm/lru_gen/enabled 2>/dev/null)"
fi

# 5) TEO idle — menu has a higher rating so it wins unless we force teo
if [ -w /sys/devices/system/cpu/cpuidle/current_governor ]; then
  echo teo >/sys/devices/system/cpu/cpuidle/current_governor 2>/dev/null || true
  log "cpuidle=$(cat /sys/devices/system/cpu/cpuidle/current_governor 2>/dev/null)"
fi
