-- toggle Alacritty opacity
hs.hotkey.bind({ "cmd" }, "u", function()
  hs.execute("toggle_opacity", true)
end)

-- ====================== TERMINAL SWITCHER ======================
-- Toggle terminal with option + space
-- Uncomment one of the following to switch between terminals:

-- ALACRITTY (Active)
hs.hotkey.bind({ "⌥" }, "space", function()
  local appName = "alacritty"
  local app = hs.application.find(appName)

  if app == nil then
    hs.application.launchOrFocus("Alacritty.app")
  elseif app:isFrontmost() then
    app:hide()
  else
    hs.application.launchOrFocus("Alacritty.app")
  end
end)

-- KITTY (Inactive)
-- hs.hotkey.bind({ "⌥" }, "space", function()
--   local appName = "kitty"
--   local app = hs.application.find(appName)
--
--   if app == nil then
--     hs.application.launchOrFocus("kitty.app")
--   elseif app:isFrontmost() then
--     app:hide()
--   else
--     hs.application.launchOrFocus("kitty.app")
--   end
-- end)

-- GHOSTTY (Inactive)
-- hs.hotkey.bind({ "⌥" }, "space", function()
--   local appName = "Ghostty"
--   local app = hs.application.find(appName)
--
--   if app == nil then
--     hs.application.launchOrFocus("Ghostty.app")
--   elseif app:isFrontmost() then
--     app:hide()
--   else
--     hs.application.launchOrFocus("Ghostty.app")
--   end
-- end)

-- toggle Warp windows
hs.hotkey.bind({ "⌥" }, "W", function()
  local appName = "Warp"
  local app = hs.application.find(appName)
  local spaces = require("hs.spaces")

  function MoveActiveScreen(app)
    local window = app:focusedWindow()
    local focused = spaces.focusedSpace()
    spaces.moveWindowToSpace(window:id(), focused)
    window:focus()
  end

  print(app)
  if app == nil then
    hs.application.launchOrFocus("Warp.app")
  elseif app ~= nil and app:isFrontmost() then
    app:hide()
  else
    MoveActiveScreen(app)
  end
end)

-- toggle Slack windows
hs.hotkey.bind({ "⌥" }, "S", function()
  local appName = "Slack"
  local app = hs.application.find(appName)
  local spaces = require("hs.spaces")

  function MoveActiveScreen(app)
    local window = app:focusedWindow()
    local focused = spaces.focusedSpace()
    spaces.moveWindowToSpace(window:id(), focused)
    window:focus()
  end

  print(app)
  if app == nil then
    hs.application.launchOrFocus("Slack.app")
  elseif app ~= nil and app:isFrontmost() then
    app:hide()
  else
    MoveActiveScreen(app)
  end
end)

-- toggle Vivaldi windows
hs.hotkey.bind({ "⌥" }, "V", function()
  local appName = "Vivaldi"
  local app = hs.application.find(appName)
  local spaces = require("hs.spaces")

  function MoveActiveScreen(app)
    local window = app:focusedWindow()
    local focused = spaces.focusedSpace()
    spaces.moveWindowToSpace(window:id(), focused)
    window:focus()
  end

  print(app)
  if app == nil then
    hs.application.launchOrFocus("Vivaldi.app")
  elseif app ~= nil and app:isFrontmost() then
    app:hide()
  else
    MoveActiveScreen(app)
  end
end)

-- toggle PyCharm windows
hs.hotkey.bind({ "⌥" }, "P", function()
  local appName = "PyCharm" 
  local app = hs.application.find(appName)
  local spaces = require("hs.spaces")

  function MoveActiveScreen(app)
    local window = app:focusedWindow()
    local focused = spaces.focusedSpace()
    spaces.moveWindowToSpace(window:id(), focused)
    window:focus()
  end

  print(app)
  if app == nil then
    hs.application.launchOrFocus("/Users/ryosukematsushima/Applications/PyCharm Professional Edition.app")
  elseif app ~= nil and app:isFrontmost() then
    app:hide()
  else
    MoveActiveScreen(app)
  end
end)

-- toggle DataGrip windows
hs.hotkey.bind({ "⌥" }, "D", function()
  local appName = "DataGrip" 
  local app = hs.application.find(appName)
  local spaces = require("hs.spaces")

  function MoveActiveScreen(app)
    local window = app:focusedWindow()
    local focused = spaces.focusedSpace()
    spaces.moveWindowToSpace(window:id(), focused)
    window:focus()
  end

  print(app)
  if app == nil then
    hs.application.launchOrFocus("/Users/ryosukematsushima/Applications/DataSpell.app")
  elseif app ~= nil and app:isFrontmost() then
    app:hide()
  else
    MoveActiveScreen(app)
  end
end)

-- toggle Obsidian windows
hs.hotkey.bind({ "⌥" }, "O", function()
  local appName = "Obsidian" 
  local app = hs.application.find(appName)
  local spaces = require("hs.spaces")

  function MoveActiveScreen(app)
    local window = app:focusedWindow()
    local focused = spaces.focusedSpace()
    spaces.moveWindowToSpace(window:id(), focused)
    window:focus()
  end

  print(app)
  if app == nil then
    hs.application.launchOrFocus("Obsidian.app")
  elseif app ~= nil and app:isFrontmost() then
    app:hide()
  else
    MoveActiveScreen(app)
  end
end)

-- toggle Finder windows
hs.hotkey.bind({ "⌥" }, "F", function()
  local appName = "Finder" 
  local app = hs.application.find(appName)
  local spaces = require("hs.spaces")

  function MoveActiveScreen(app)
    local window = app:focusedWindow()
    local focused = spaces.focusedSpace()
    spaces.moveWindowToSpace(window:id(), focused)
    window:focus()
  end

  print(app)
  if app == nil then
    hs.application.launchOrFocus(appName)
  elseif app ~= nil and app:isFrontmost() then
    app:hide()
  else
    MoveActiveScreen(app)
  end
end)

-- toggle Notion windows
hs.hotkey.bind({ "⌥" }, "N", function()
  local appName = "Notion" 
  local app = hs.application.find(appName)
  local spaces = require("hs.spaces")

  function MoveActiveScreen(app)
    local window = app:focusedWindow()
    local focused = spaces.focusedSpace()
    spaces.moveWindowToSpace(window:id(), focused)
    window:focus()
  end

  print(app)
  if app == nil then
    hs.application.launchOrFocus("Notion.app")
  elseif app ~= nil and app:isFrontmost() then
    app:hide()
  else
    MoveActiveScreen(app)
  end
end)

-- toggle Cursor windows
hs.hotkey.bind({ "⌥" }, "C", function()
  local appName = "Cursor" 
  local app = hs.application.find(appName)
  local spaces = require("hs.spaces")

  function MoveActiveScreen(app)
    local window = app:focusedWindow()
    local focused = spaces.focusedSpace()
    spaces.moveWindowToSpace(window:id(), focused)
    window:focus()
  end

  print(app)
  if app == nil then
    hs.application.launchOrFocus("Cursor.app")
  elseif app ~= nil and app:isFrontmost() then
    app:hide()
  else
    MoveActiveScreen(app)
  end
end)

-- toggle IntelliJ IDEA windows
hs.hotkey.bind({ "⌥" }, "I", function()
  local appName = "IntelliJ"
  local app = hs.application.find(appName)
  local spaces = require("hs.spaces")

  function MoveActiveScreen(app)
    local window = app:focusedWindow()
    local focused = spaces.focusedSpace()
    spaces.moveWindowToSpace(window:id(), focused)
    window:focus()
  end

  print(app)
  if app == nil then
    hs.application.launchOrFocus("/Users/ryosukematsushima/Applications/IntelliJ IDEA Ultimate.app")
  elseif app ~= nil and app:isFrontmost() then
    app:hide()
  else
    MoveActiveScreen(app)
  end
end)

--------------------------------------------------------------------------------
-- Conditional Menubar Items (Bartender Triggers alternative)
--------------------------------------------------------------------------------

-- Battery indicator (show only when < 20% and not charging)
local batteryItem = hs.menubar.new(false)

local function updateBattery()
  local pct = hs.battery.percentage()
  local charging = hs.battery.isCharging()

  if pct and pct < 20 and not charging then
    batteryItem:returnToMenuBar()
    batteryItem:setTitle(("🔋%d%%"):format(math.floor(pct)))
    batteryItem:setMenu({
      { title = "バッテリー設定を開く", fn = function()
          hs.execute('open -a "System Settings"', true)
        end },
      { title = "省エネルギーモードを有効化", fn = function()
          hs.execute('sudo pmset -a lowpowermode 1', true)
        end },
    })
  else
    batteryItem:removeFromMenuBar()
  end
end

-- WiFi indicator (show only when disconnected)
local wifiItem = hs.menubar.new(false)

local function updateWiFi()
  local ssid = hs.wifi.currentNetwork()

  if ssid == nil then
    wifiItem:returnToMenuBar()
    wifiItem:setTitle("📶×")
    wifiItem:setMenu({
      { title = "ネットワーク設定を開く", fn = function()
          hs.execute('open -a "System Settings"', true)
        end },
      { title = "Wi-Fi を入れ直す", fn = function()
          hs.execute('/usr/sbin/networksetup -setairportpower en0 off; sleep 1; /usr/sbin/networksetup -setairportpower en0 on', true)
        end },
    })
  else
    wifiItem:removeFromMenuBar()
  end
end

-- Start watchers
hs.battery.watcher.new(updateBattery):start()
hs.wifi.watcher.new(updateWiFi):start()

-- Initial update
updateBattery()
updateWiFi()
