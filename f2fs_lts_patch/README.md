# F2FS LTS 修复（atomic / write_end_io / inline fiemap）

来源 AOSP `android14-6.1-lts`，已在一加 12 OKI 树上试合。
独立开关 `f2fs_lts`，默认开；和 QCOM / android_lts / PSI 无文件冲突。

| 补丁 | 作用 |
|---|---|
| 001 | 原子写 GC 时 `igrab` `atomic_inode`，evict 时在 `i_sem` 下清指针，避免 UAF |
| 002 | `f2fs_write_end_io()` 先摘 fsync node，再 `dec_page_count`（对照一加树手改） |
| 003 | unwritten inline inode 的 fiemap 不再编造磁盘地址 |

没合（欧加改过对不上，或会误伤分配方式）：

- discard_cmd_cnt / remount 超时参数
- lockdep `cp_global_sem` 假阳性
- `kvfree` → `kfree`（一加这边还是 `kvmalloc`/`kvfree`）

刷完重点：微信/相册写库、拍照连拍、长时间后台 GC。异常就把 Action 里 `f2fs_lts` 关掉。
