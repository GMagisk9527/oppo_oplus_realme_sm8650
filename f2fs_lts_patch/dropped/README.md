# Dropped from default f2fs_lts

纯 UAF / 少见路径，日用几乎感觉不到：

- 001 原子写 GC `atomic_inode` UAF
- 002 `f2fs_write_end_io` 先摘 fsync node
- 003 unwritten inline fiemap 编造磁盘地址
- 004 原子写期间禁止 DIO
- 006 fiemap/seek/verity 用 per-inode `maxbytes`

要合回去：移回 `f2fs_lts_patch/`，按编号顺序试合（002/006 都改 `data.c`）。
