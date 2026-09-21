# Dropped from default android_lts

纯 UAF / 泄漏 / 日志 / 少见竞态，日用几乎感觉不到：

- 003 futex robust list exec 泄漏
- 004 wakeup 空链表 walk
- 005 futex 清过期 exiting
- 008 binder 冻结回包日志（只改 log）
- 009 futex robust exit 竞态
- 010 wakelock 上限 off-by-one
- 011 futex rcuwait UAF（PREEMPT_RT，这棵树不是 RT）
- 012 binder 去掉非法 weak-inc
- 013 binder 释放事务 pin `to_thread` UAF
- 016 RCU nocb 空 kthread 指针
- 017 RCU `defer_qs_iw_pending` 竞态
- 018 `call_rcu` 空回调
- 021 MGLRU `shrink_many` lruvec UAF

要合回去：移回 `android_lts_patch/`。011 依赖 006 的 `requeue.c` 上下文，必须在 006 之后。
