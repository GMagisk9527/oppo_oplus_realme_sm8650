# Dropped from default ack_backport

日用几乎感觉不到，或补丁本身还不干净：

- 002 xhci ep0 maxpacket on reset：`xhci_endpoint_reset()` 用 `devs[udev->slot_id]` **没判 vdev**。slot 未建/已拆会空指针。厂商原路径先看 `host_ep->hcpriv` 再判 `vdev`。加回前要补空判。
- 003 xhci urb enqueue：把 `xhci_vendor_usb_offload_skip_urb()` 挪到 `if (!urb)` 前面。加回前应先判 `urb`。002/003 改同一段 `xhci.c`，一起丢。
- 004 NFC LLCP TLV 越界（几乎没人用系统 NFC LLCP）
- 005 蓝牙 LE Audio BIG `create_big_sync` 连接对象 UAF
- 006 PSI trigger 改 kernfs notify（cgroup 删除时 poller UAF）
- 007 006 的 ABI 配套（`psi_trigger_ext`）
- 008 PM：`pm_wq` 去 `WQ_FREEZABLE` 改 `WQ_UNBOUND`；`__device_suspend_late()` 用 `pm_runtime_disable()` 会等在途 RPM。厂商原来 `__pm_runtime_disable(dev, false)` 不等。不是开机根因（SSG 才是），但第一次 suspend / charger RPM 仍可能卡住。

先前把 002/003/008 当开机元凶是误判。一加 12 开不了机是 **SSG**，已默认关。
