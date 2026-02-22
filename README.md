# dotfiles

## Caps Lock 重映射：可靠的大写切换 + 中英互斥解决

解决 macOS 上两个常见痛点：

- **大写切换不可靠**：原生 Caps Lock 切换大小写和中英切换同一键位,极其容易误触
- **中文输入法打大写字母**：开启大写后如果是鼠须管（Rime）输入法，会导致中文输入法输入大写字母,所以写了互斥逻辑
  
>很难想象2026年的今天,苹果居然连中文用户的大小写切换以及中英文切换的逻辑都做不好,并且第三方软件实现起来极其复杂,故写此dotfiles repo供有相同问题的人ai websearch能解决问题

---

### 效果

| 操作 | 结果 |
|------|------|
| `Shift + Caps Lock` | 切换大小写状态 |
| `Caps Lock` | 切换中英文 |
| 切换到大写 | 自动切换到 ABC 输入法 |
| 大写状态下手动切到鼠须管 | 立即被打回 ABC |
| 关闭大写 | 输入法不变，可自由切换 |

---

### 依赖

- [Karabiner-Elements](https://karabiner-elements.pqrs.org/)
- [Hammerspoon](https://www.hammerspoon.org/)
> karabiner来操控快捷键映射,hammerspoon监测状态,因为macos26的权限缩紧karabiner无法单独完成任务
---

### 原理

macOS 原生 Caps Lock 有两个问题：在中文输入法下状态同步不稳定，且没有机制约束大写时只用英文输入法。

方案分两层：

**第一层：Karabiner-Elements**

将 `Shift + Caps Lock` 映射为 `Shift + F19`（发出 Shift+F19 而非裸 F19 的原因：Karabiner 处理 mandatory modifier 时会临时抬起再恢复 Shift，这个孤立的 Shift keyup/keydown 会被 macOS 输入源切换机制捕获，导致意外切换输入法。把 Shift 也带入 `to` 事件，Karabiner 无需抬起恢复，问题消除）。

**第二层：Hammerspoon**

监听 `Shift + F19`，每次触发时直接读取系统真实的 Caps Lock 状态（`hs.hid.capslock.get()`）再取反，避免本地变量与系统状态不同步。

同时通过 macOS 原生分布式通知 `TISNotifySelectedKeyboardInputSourceChanged` 监听所有输入源变更事件，只要大写状态为开就强制切回 ABC。

**系统设置:

需要关闭设置->键盘->输入法编辑->使用大写键"切换ABC"输入法


---

### 安装

**1. Karabiner-Elements**

打开 Karabiner-Elements → Complex Modifications → Add rule → 选择 Import more rules from the Internet，或直接手动添加：

将 `karabiner/shift_capslock_f19.json` 中的规则添加到你的 `~/.config/karabiner/karabiner.json` 的 `manipulators` 数组中。

**2. Hammerspoon**

将 `hammerspoon/init.lua` 复制到 `~/.hammerspoon/init.lua`，然后在 Hammerspoon 中执行 `hs.reload()`。

如果你已有 `init.lua`，将文件内容合并进去即可。

>如果有claude code建议brew下载了这两个软件之后直接让claude来进行合并配置

---

### 文件说明

```
dotfiles/
├── hammerspoon/
│   └── init.lua                  # Hammerspoon 配置
└── karabiner/
    └── shift_capslock_f19.json   # Karabiner 规则片段
```
