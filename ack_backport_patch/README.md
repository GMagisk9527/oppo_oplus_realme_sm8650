# ACK backports not yet in the LTS branch

来源 **AOSP `kernel/common` 的 `android14-6.1`（非 LTS）分支**，也就是比 `android14-6.1-lts` 还新的那一批。
这些提交还没被合进 LTS 分支（LTS 目前只跟到 stable 6.1.177），但在一加 12 OKI 树上能顺序合上。

独立开关 `ack_backport`，默认开；在 QCOM → android_lts → aosp_psi → f2fs_lts 之后合。

| 补丁 | 作用 |
|---|---|
| 001 | wifi 关闭时把 P2P device / NAN 一起停掉（原来只处理 netdev，suspend 和 socket owner 场景会漏） |
| 002 | ep0 max packet size 改到 `xhci_endpoint_reset()` 里做，不在每次 urb enqueue 检查 |
| 003 | urb 入队期间持 xhci 锁再解引用 device，堵断开瞬间的 UAF；错误路径统一走 `free_priv` |
| 004 | NFC LLCP `connect_sn` 的 TLV 遍历限制在 skb 内 |
| 005 | 蓝牙 `create_big_sync`（LE Audio BIG）的连接对象 UAF：加 `hci_conn_valid()` + 跨异步边界持引用 |
| 006 | PSI trigger 改走 kernfs notify，修 cgroup 被删时 poller 踩已释放 waitqueue 的 UAF |
| 007 | 006 的 ABI 配套：把新增字段挪进 `psi_trigger_ext`，不动 `struct psi_trigger` 布局 |
| 008 | `pm_wq` 去掉 `WQ_FREEZABLE` 加 `WQ_UNBOUND`；`__device_suspend_late()` 改用 `pm_runtime_disable()` 等住在途 runtime PM（**对照一加树手改**，树上函数名是 `pm_start_workqueue()`） |

002/003 和 006/007 是顺序依赖的，必须按编号合。

没合：

- `posix-cpu-timers` 非 leader exec UAF：真 UAF，但一次引入 100 多行还改 exit/signal 主路径，风险大于收益
- `fuse-bpf` backing inode double iput：只有 FUSE_BPF backing file 场景，手机用不到
- `PM: Support to abort suspend during filesystem sync`：要 `pm_fs_abort` 模块参数才生效，默认关

刷完重点：开关 wifi/蓝牙/NFC、USB 插拔（MTP、OTG、U 盘）、亮灭屏 suspend/resume。异常就把 Action 里 `ack_backport` 关掉。
