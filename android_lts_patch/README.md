# Android LTS 修复（futex / binder / freezer / RCU / MGLRU）

来源 linux-stable `v6.1.141..v6.1.188`，已在一加 12 OKI 树上按顺序试合。
和 `qcom_lts_patch` 无文件冲突，编译时先合 QCOM 再合这一组。

| 类 | 补丁 | 作用 |
|---|---|---|
| futex | 001,003,005,006,009,011 | requeue-PI UAF/死锁、robust list 泄漏、exit 竞态 |
| dma-buf | 002 | `dma_resv_wait_timeout` 超时处理 |
| wakeup / alarm | 004,007,010 | wakeup 空链表、alarmtimer 参数顺序、wakelock 上限 off-by-one |
| binder | 008,012,013 | 冻结回包日志、错误 weak-inc、释放事务时 pin `to_thread`（防 UAF） |
| freezer | 014,015 | 挂到冻结 cgroup 时先清 FROZEN 再 freeze；撤回会让任务解冻逃逸的 `cgroup_freezing()` 判断 |
| RCU | 016,017,018 | nocb 空 kthread、`defer_qs_iw_pending` 竞态、`call_rcu` 空回调 |
| MGLRU | 019,020 | look_around 跳过 `VM_SPECIAL`；reclaim 循环报 RCU-tasks QS |

013 / 019 是对照一加树手改的：vendor hook 和 CHP 改过上下文，stable 原补丁对不上。

没合（一加改过对不上，或这棵 Image 用不上）：

- binder `thread_release`/`free_transaction` 的原版 hunk、offsets overwrite、shrinker UAF
- FUSE livelock / readahead
- fair.c PELT
- UFS hang / lrbp / init UAF（`ufshcd.c` 厂商改太多）
- workqueue watchdog（上下文对不上；PSI 时钟那笔树里已经有了）
- memcg 超限睡眠的全局 PSI 记账：单独在 `aosp_psi_patch`，默认开，开关 `aosp_psi`

刷完重点：多开 App、锁屏、相机预览、播放器（futex/binder）；开了 Re-Kernel/冻结再看切后台。异常就把 Action 里 `android_lts` 关掉。
