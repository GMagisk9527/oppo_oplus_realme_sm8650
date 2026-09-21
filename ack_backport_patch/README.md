# ACK backports not yet in the LTS branch

来源 **AOSP `kernel/common` 的 `android14-6.1`（非 LTS）分支**，也就是比 `android14-6.1-lts` 还新的那一批。
独立开关 `ack_backport`，默认开；在 QCOM → android_lts → aosp_psi → f2fs_lts 之后合。

| 补丁 | 作用 |
|---|---|
| 001 | wifi 关闭时把 P2P device / NAN 一起停掉（原来只处理 netdev，suspend 和 socket owner 场景会漏） |
| 004 | NFC LLCP `connect_sn` 的 TLV 遍历限制在 skb 内 |
| 005 | 蓝牙 `create_big_sync`（LE Audio BIG）的连接对象 UAF：加 `hci_conn_valid()` + 跨异步边界持引用 |
| 006 | PSI trigger 改走 kernfs notify，修 cgroup 被删时 poller 踩已释放 waitqueue 的 UAF |
| 007 | 006 的 ABI 配套：把新增字段挪进 `psi_trigger_ext`，不动 `struct psi_trigger` 布局 |

006/007 顺序依赖，必须按编号合。

**从默认包拿掉（`dropped/`）**：`c4cc084` 开不了机、`acbd3d2` 能开，差的就是这批 ACK。开机必经 USB 枚举，最像：

- **002** `xhci_endpoint_reset()` 对 ep0 用 `container_of(host_ep, usb_device, ep0)` 再 `xhci->devs[udev->slot_id]`，**没判 vdev**。slot 还没建或已拆时直接空指针。厂商原路径是先看 `host_ep->hcpriv` 再判 `vdev`。
- **003** 把 `xhci_vendor_usb_offload_skip_urb()` 挪到 `xhci_check_args()` / `if (!urb)` 前面，厂商 USB offload 钩子可能踩空 urb/ep。002/003 绑在一起改 `xhci.c`，两条一起丢。
- **008** `pm_wq` 去掉 `WQ_FREEZABLE` 改 `WQ_UNBOUND`，`__device_suspend_late()` 改 `pm_runtime_disable()` 会**等在途 runtime PM**。厂商原来是 `__pm_runtime_disable(dev, false)` 不等。开机第一次 suspend 或 charger/UFS RPM 卡住就会黑屏。

没合：posix-cpu-timers 非 leader exec UAF、fuse-bpf double iput、`pm_fs_abort`。

刷完重点：开关 wifi/蓝牙/NFC。异常就把 Action 里 `ack_backport` 关掉。
