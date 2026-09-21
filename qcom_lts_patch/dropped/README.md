# Dropped from default qcom_lts

纯崩溃 / 探测期 / 调试，日用几乎感觉不到：

- 001 QMP USB `NULL` vs `IS_ERR`
- 004 UIC get 失败时清垃圾 `mib_val`
- 005 smem hwspinlock 泄漏
- 006 UFS string desc 多拷了 length/type
- 007 suspend 失败写 event history（调试）
- 009 只有一个 idle 状态时跳过 governor（PowerNV / 单 snooze，SM8650 用不上）
- 010 RPM0 时 flush EH work（崩溃防护）
- 011 cmd-db `devm_memremap`
- 012 smem probe `-ENOMEM`
- 013 总是 init UIC completion（013 的后续 hang 修复一加树对不上）
- 015 SNPS femto v2 空指针

要合回去：把文件移回 `qcom_lts_patch/`，按编号顺序试合。
