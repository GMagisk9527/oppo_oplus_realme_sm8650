# 主线 backport（默认只留 UFS busy-loop / f2fs 压缩死循环）

来源 linux-stable 6.6/6.12/6.18，6.1.188 没有同主题。
开关 `mainline_bp`，默认开。在 ack_backport 之后合。

| 补丁 | 日用收益 |
|---|---|
| 001 | UFS doorbell 等待先 `TASK_UNINTERRUPTIBLE`，否则 `io_schedule_timeout()` 立刻返回空转烧 CPU |
| 006 | 压缩覆写碰到 IO error 不再死循环占 writeback 锁（这棵树开了 `F2FS_FS_COMPRESSION`） |

PHY 空指针、ckpt sysfs、valid-count 泄漏、gadget `num_buffers`、多余 `wmb()` 在 `dropped/`。

刷完重点：亮灭屏、相册写压缩文件。异常就把 Action 里 `mainline_bp` 关掉。
