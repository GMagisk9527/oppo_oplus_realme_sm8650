# Android LTS（默认只留日用能感到的）

来源 linux-stable `v6.1.141..v6.1.188`。先合 QCOM 再合这一组。
开关 `android_lts`，默认开。纯 UAF / 空链表 / 日志在 `dropped/`。

| 补丁 | 日用收益 |
|---|---|
| 001 | 006 的前置（requeue-PI 先读 `q->task`）；单独是 UAF，跟着 006 走 |
| 002 | `dma_resv_wait_timeout(0)` 不再空等 1 jiffy（GPU/显示 fence 轮询） |
| 006 | requeue-PI 超时/信号时不再和 requeue 端互抢 hb lock 卡死 |
| 007 | alarmtimer `forward` 参数顺序，周期闹钟不再算错 overrun |
| 014 | 任务挂进已冻结 cgroup 会真正冻住（配合 Re-Kernel / freezer） |
| 015 | 撤回会让已冻任务自己解冻跑掉的 `cgroup_freezing()` 判断 |
| 019 | MGLRU look_around 跳过 `VM_SPECIAL`，少扫无用页 |
| 020 | reclaim 循环报 RCU-tasks QS，避免长时间回收把 tasks-RCU 拖成 stall |

刷完重点：多开、锁屏、相机预览、切后台冻结。异常就把 Action 里 `android_lts` 关掉。
