# 主线 6.6–6.18 独立 backport

来源 linux-stable **6.6.y / 6.12.y / 6.18.y**，6.1.188 没有同主题。
只留在 `oneplus/sm8650_b_16.0.0_oneplus12_6.1.141` 上能合上的独立修复，不搬 folio / EEVDF / WALT。

独立开关 `mainline_bp`，默认开；在 QCOM → android_lts → aosp_psi → f2fs_lts → ack_backport 之后合。

| 补丁 | 上游 | 作用 |
|---|---|---|
| 001 | 6.6/6.12/6.18 `scsi: ufs: core: Set task state before io_schedule_timeout()` | doorbell 等待循环先 `TASK_UNINTERRUPTIBLE`，否则 `io_schedule_timeout()` 立刻返回空转 |
| 002 | 6.6 `scsi: ufs: core: Remove unnecessary wmb() after ringing doorbell` | TM doorbell 去掉多余 `wmb()` |
| 003 | 6.12 `phy: qcom: qmp-usb: Fix possible NULL-deref on early runtime suspend` | runtime PM 窗口里 `qphy->phy` 还没建好就解引用（**对照一加树手改**，结构还是 `qmp_phy`） |
| 004 | 6.12 `f2fs: avoid NULL checkpoint thread access in sysfs` | `ckpt_thread_ioprio` 在没有 ckpt 线程时不踩空指针 |
| 005 | 6.12 `f2fs: fix valid block count leak on data block allocation failure` | `f2fs_allocate_data_block()` 失败回滚 `inc_valid_block_count` |
| 006 | 6.12 `f2fs: fix potential deadloop in prepare_compress_overwrite()` | 压缩覆写 IO error 不再死循环占 writeback 锁（**对照一加树手改**，`f2fs_handle_page_eio` 仍吃 `pgoff_t`） |
| 007 | 6.18 `usb: gadget: f_mass_storage: fix null pointer dereference in fsg_common_set_num_buffers()` | MTP/U 盘 gadget `num_buffers < 2` 直接 EINVAL |

没合（试过，6.1 树对不上、依赖 folio、或要新 API）：

- `PM: sleep: Unblock runtime PM when device prepare fails`：要 `pm_runtime_unblock()` / `RPM_BLOCKED`，6.1 没有
- UFS `host_lock` 绕 UTMRLDBR / Cancel RTC work：一加 `ufshcd.c` 上下文对不上
- f2fs post-EOF zero / pinfile fragment / curseg migrate：folio 或欧加改太多
- PSI `psimon` 挪出 `cgroup_mutex`、MGLRU folio unevictable、dma-heap fd_install 顺序：要 6.6+ 结构
- Bluetooth ISO/hci_sync、xhci Missed Service Error、qcom scm tzmem：文件布局已变

刷完重点：亮灭屏 UFS、USB/MTP、相册写库、压缩文件。异常就把 Action 里 `mainline_bp` 关掉。
