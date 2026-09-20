# AOSP power defaults (一加 12 / 6.1.141)

编译和刷入时默认做这 5 项。出问题可在 GitHub Action / 本地脚本里关掉 `aosp_power`。

| # | 项 | 做法 |
|---|---|---|
| 1 | RCU Lazy | `CONFIG_RCU_NOCB_CPU_DEFAULT_ALL=y`，关掉 `RCU_LAZY_DEFAULT_OFF`，cmdline `rcu_nocbs=all rcutree.enable_rcu_lazy=1` |
| 2 | 关 schedstats | cmdline `schedstats=disable`，开机后再写 `/proc/sys/kernel/sched_schedstats` |
| 3 | power-efficient workqueue | cmdline `workqueue.power_efficient=1`，并尝试 `CONFIG_WQ_POWER_EFFICIENT_DEFAULT=y` |
| 4 | MGLRU | 树里已是 `CONFIG_LRU_GEN_ENABLED=y`；开机脚本再钉一次 sysfs |
| 5 | TEO idle | cmdline `cpuidle.governor=teo`（menu 的 rating 更高，不强制会走 menu） |

回退：刷回上一包，或 cmdline 改成 `rcutree.enable_rcu_lazy=0 cpuidle.governor=menu workqueue.power_efficient=0`。

开机后（root）：

```sh
grep -oE 'rcutree.enable_rcu_lazy=[^ ]+|rcu_nocbs=[^ ]+|workqueue.power_efficient=[^ ]+|cpuidle.governor=[^ ]+|schedstats=[^ ]+' /proc/cmdline
cat /proc/sys/kernel/sched_schedstats
cat /sys/kernel/mm/lru_gen/enabled
cat /sys/devices/system/cpu/cpuidle/current_governor
```

预期：lazy=1、schedstats=0、lru_gen 非 0、governor=teo。
