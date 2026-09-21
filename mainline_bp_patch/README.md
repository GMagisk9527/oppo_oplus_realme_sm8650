# 主线 backport（默认只留日用能感到的）

来源 linux-stable 6.6/6.12/6.18 和 7.1–7.3 能干净 backport 的独立修。
开关 `mainline_bp`，默认开。在 ack_backport 之后合。

| 补丁 | 日用收益 |
|---|---|
| 001 | UFS doorbell 等待先 `TASK_UNINTERRUPTIBLE`，否则 `io_schedule_timeout()` 立刻返回空转烧 CPU |
| 006 | 压缩覆写碰到 IO error 不再死循环占 writeback 锁（这棵树开了 `F2FS_FS_COMPRESSION`） |
| 007 | atomic fsync 和 truncate 抢同一 node page 时不再 `goto retry` 死循环 |
| 008 | PSI irqtime 热路径：没新 IRQ 时间就直接返回，少走 cgroup 链 |
| 009 | MGLRU walk 用 `mmgrab` 不抬 `mm_users`，杀进程 / `process_mrelease` 不再被 kswapd 钉住 |

PHY 空指针、ckpt sysfs、valid-count 泄漏、gadget `num_buffers`、多余 `wmb()` 在 `dropped/`。

刷完重点：亮灭屏、相册写压缩文件、杀后台、多开。异常就把 Action 里 `mainline_bp` 关掉。
