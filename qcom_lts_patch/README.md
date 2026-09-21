# QCOM / LTS（默认只留日用能感到的）

来源 linux-stable `v6.1.141..v6.1.188`，以及 6.16/7.2 能干净 backport 的独立 UFS 省电修。
开关 `qcom_lts`，默认开。空指针 / 探测期泄漏在 `dropped/`，apply.sh 不会合进去。

| 补丁 | 日用收益 |
|---|---|
| 002 | hibern8 退出失败改 link recovery（只在 `wl_resume`，suspend 进 h8 不再乱 recovery），避免 runtime resume 和 error handler 互卡 |
| 003 | rpmh TCS 完成后清 TRIGGER，避免假 completion IRQ 把深睡眠打醒 |
| 008 | W-LUN resume 失败后 error handler 能把 parent 拉起来，存储不会一直 RPM 错误 |
| 014 | AOSS cooling 按归一化状态比较，少发重复 QMP 投票 |
| 016 | Auto-Hibern8 后开 `UFS_HW_CLK_CTRL_EN`，控制器进 H8 时自己拉低 clk_req，GCC 能关闲时钟 |
| 017 | QUnipro 内部 CGC（DL/PA/DME），UTP 之外 Unipro 也能门控 |

刷完重点：亮灭屏、充电、待机掉电。异常就把 Action 里 `qcom_lts` 关掉。
