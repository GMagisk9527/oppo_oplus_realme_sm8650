# QCOM / LTS（默认只留日用能感到的）

来源 linux-stable `v6.1.141..v6.1.188`，已在一加 12 OKI 上试合。
开关 `qcom_lts`，默认开。空指针 / 探测期泄漏在 `dropped/`，apply.sh 不会合进去。

| 补丁 | 日用收益 |
|---|---|
| 002 | hibern8 退出失败改 link recovery，避免 runtime resume 和 error handler 互卡（亮灭屏 UFS 卡住） |
| 003 | rpmh TCS 完成后清 TRIGGER，避免假 completion IRQ 把深睡眠打醒 |
| 008 | W-LUN resume 失败后 error handler 能把 parent 拉起来，存储不会一直 RPM 错误 |
| 014 | AOSS cooling 按归一化状态比较，少发重复 QMP 投票 |

刷完重点：亮灭屏、充电、待机掉电。异常就把 Action 里 `qcom_lts` 关掉。
