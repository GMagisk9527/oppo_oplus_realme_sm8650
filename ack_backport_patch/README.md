# ACK backport（默认只留关 wifi 停 NAN/P2P）

来源 AOSP `kernel/common` `android14-6.1`（非 LTS）。
开关 `ack_backport`，默认开。在 QCOM → android_lts → aosp_psi → f2fs_lts 之后合。

| 补丁 | 日用收益 |
|---|---|
| 001 | 关 wifi / suspend / socket owner 离开时把 P2P device 和 NAN 一起停掉，避免后台还扫 |

NFC TLV、蓝牙 BIG UAF、PSI trigger UAF、xhci、PM 都在 `dropped/`。
xhci 002/003 和 PM 008 **不是**开机根因（根因是 SSG），但 002 缺 `vdev` 空判、003 把 vendor offload 挪到 `if (!urb)` 前，加回前要先改补丁。

刷完重点：开关 wifi。异常就把 Action 里 `ack_backport` 关掉。
