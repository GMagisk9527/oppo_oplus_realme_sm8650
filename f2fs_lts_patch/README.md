# F2FS LTS（默认只留 discard 记账）

来源 AOSP `android14-6.1-lts`。开关 `f2fs_lts`，默认开。
原子写 UAF / fiemap 地址 / DIO 禁止在 `dropped/`。

| 补丁 | 日用收益 |
|---|---|
| 005 | checkpoint 时当前段 0 valid block 也要建 discard_cmd，否则 `discard_blks` 永不归零，后台 GC/trim 一直空转 |

刷完重点：长时间后台、相册写库后待机。异常就把 Action 里 `f2fs_lts` 关掉。
