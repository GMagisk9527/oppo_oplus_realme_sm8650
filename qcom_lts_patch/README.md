# QCOM / LTS 修复（6.1.141 → 6.1.188，已在一加 12 OKI 上试合）

来源是 linux-stable，不是 6.12 主线，也不是整棵 CLO。
只留在 `oneplus/sm8650_b_16.0.0_oneplus12_6.1.141` 上能干净 apply 的独立修复。

| 类别 | 补丁 | 作用 |
|---|---|---|
| UFS | 002,004,006,007,008,010,013 | hibern8 退出失败做 link recovery、异常处理、字符串描述符、UIC completion |
| rpmh / cmd-db / smem / aoss | 003,005,011,012,014 | idle 投票、共享内存泄漏、AOSS 散热状态比较 |
| USB PHY | 001,015 | QMP / SNPS femto 空指针 |
| cpuidle | 009 | 只有一个 idle 状态时跳过 governor |

没合进去的（试过，一加改过 `ufshcd.c` 对不上，或平台用不上）：

- UFS error handler hang / lrbp->cmd / UAF / 把 recovery 挪到 wl_resume
- ocmem、LLCC v1、qcom-spm（老 SPM idle）
- WALT / GPU / Wi‑Fi 模块（不在这棵 Image 里）

刷完重点看：开机、UFS 亮灭屏、充电、USB。异常就把 Action 里 `qcom_lts` 关掉重编。
