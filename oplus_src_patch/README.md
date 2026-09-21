# 一加 6.1.141 源码热路径（默认只留日用能感到的）

直接看官方 OKI 热路径，不是 LTS/主线 commit 列表。开关 `oplus_src`，默认开。在 mainline_bp 之后合。

| 补丁 | 日用收益 |
|---|---|
| 001 | 欧加 `krn_reliab` 锁监控编进 mutex/rwsem 快路径、每次 `schedule()`，以及 cgroup/fs 用的 `percpu_down_read`。默认 debug 关着，但仍出函数（CFI 更亏）。改成 jump label，关着就是 NOP；`/proc/krn_reliab/debug_enable` 仍能打开 |
| 002 | `CONFIG_TASK_DELAY_ACCT` 关着，vendor 兜底仍从 `schedule()` iowait / fork / reclaim 出函数问 `get_delayacct_enabled()`。改成 jump label，关着就是 NOP；`set_delayacct_enabled()` 仍能打开 |

刷完重点：滑动、多开、锁竞争、存储卡顿后回前台。异常就把 Action 里 `oplus_src` 关掉。
