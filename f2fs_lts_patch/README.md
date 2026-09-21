# F2FS LTS（默认只留 discard 记账 / 冻得住 / shrink）

来源 AOSP `android14-6.1-lts` 和 7.1/7.2 独立小修。开关 `f2fs_lts`，默认开。
原子写 UAF / fiemap 地址 / DIO 禁止在 `dropped/`。

| 补丁 | 日用收益 |
|---|---|
| 005 | checkpoint 时当前段 0 valid block 也要建 discard_cmd，否则 `discard_blks` 永不归零，后台 GC/trim 一直空转 |
| 007 | GC / discard 循环碰到 freezing 就收工，灭屏 suspend 少被 trim/GC 拖住 |
| 008 | shrinker 已经够数就不再扫 read extent tree，内存紧时少做无用活 |

刷完重点：长时间后台、相册写库后待机、灭屏。异常就把 Action 里 `f2fs_lts` 关掉。
