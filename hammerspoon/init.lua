require("hs.ipc")

local squirrelSource = "im.rime.inputmethod.Squirrel.Hans"
local abcSource = "com.apple.keylayout.ABC"
local lastFire = 0

local function ensureABCIfCaps()
    if hs.hid.capslock.get() and hs.keycodes.currentSourceID() == squirrelSource then
        hs.keycodes.currentSourceID(abcSource)
    end
end

hs.hotkey.bind({"shift"}, "f19", function()
    local now = hs.timer.secondsSinceEpoch()
    if now - lastFire < 0.2 then return end  -- 200ms 防抖
    lastFire = now

    hs.hid.capslock.set(not hs.hid.capslock.get())
    ensureABCIfCaps()
end)

-- 大写状态下禁止切换到鼠须管（监听 macOS 原生输入源变更通知）
local inputSourceWatcher = hs.distributednotifications.new(
    ensureABCIfCaps,
    "com.apple.Carbon.TISNotifySelectedKeyboardInputSourceChanged"
):start()
