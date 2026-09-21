# F2FS LTS 修复（atomic / write_end_io / inline fiemap / DIO）

来源 AOSP `android14-6.1-lts`，已在一加 12 OKI 树上按顺序试合。
独立开关 `f2fs_lts`，默认开；和 QCOM / android_lts / PSI 无文件冲突。

| 补丁 | 作用 |
|---|---|
| 001 | 原子写 GC 时 `igrab` `atomic_inode`，evict 时在 `i_sem` 下清指针，避免 UAF |
| 002 | `f2fs_write_end_io()` 先摘 fsync node，再 `dec_page_count`（对照一加树手改） |
| 003 | unwritten inline inode 的 fiemap 不再编造磁盘地址 |
| 004 | 原子写期间同时拿 `i_gc_rwsem` 读半，禁止对 atomic file 走 DIO |
| 005 | checkpoint 时当前段 0 valid block 也要建 discard_cmd，否则 `discard_blks` 永不归零 |
| 006 | fiemap/seek/verity 用 per-inode block 上限，不再用 `s_maxbytes` |

没合（欧加改过对不上，或会误伤分配方式）：

- discard_cmd_cnt / remount 超时参数
- lockdep `cp_global_sem` 假阳性
- `kvfree` → `kfree`（一加这边还是 `kvmalloc`/`kvfree`）

核对过、一加树上已经有的（不用重复合）：

- `f2fs_abort_atomic_write()` 的 `f2fs_inode_synced()`
- `f2fs_expand_inode_data()` 的 `pin_sem` 提前 + `SBI_CP_DISABLED` 检查
- `reserve_compress_blocks()` 的 `reserved && to_reserved == 1`
- `do_checkpoint()` 的 `invalidate_inode_pages2_range()`

刷完重点：微信/相册写库、拍照连拍、长时间后台 GC、大文件 seek/fiemap。异常就把 Action 里 `f2fs_lts` 关掉。
