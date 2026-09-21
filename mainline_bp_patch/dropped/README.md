# Dropped from default mainline_bp

纯空指针 / 计数泄漏 / 微优化：

- 002 TM doorbell 去掉多余 `wmb()`（正确性，几乎测不到）
- 003 QMP USB runtime 未初始化就解引用
- 004 f2fs `ckpt_thread_ioprio` 空线程
- 005 `f2fs_allocate_data_block()` 失败回滚 valid count
- 007 USB gadget `num_buffers < 2` EINVAL

要合回去：移回 `mainline_bp_patch/`。001/002 都改 `ufshcd.c`，002 在 001 之后；005/006 都改 `data.c`，006 在 005 之后。
