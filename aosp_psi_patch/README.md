# AOSP PSI：memcg 超限睡眠不算全局 stall

来源 AOSP `android14-6.1-lts` `e7abc85f1ccc`。开关 `aosp_psi`，默认开。

`memory.high` 超限后内核会 `schedule_timeout_killable()` 限速分配。这段延迟以前记进全局 PSI，容易被当成整机内存吃紧（冻结、调度、省电策略会跟着误判）。

这里只拿掉这段 **策略睡眠** 的 PSI；真正的 reclaim（`reclaim_high` / `try_charge`）仍记账。

没加 AOSP 那个 vendor hook：会多一个 GKI tracepoint，这棵一加树没导出。

刷完重点：多开吃内存、切后台、冻结。异常就把 Action 里 `aosp_psi` 关掉。
