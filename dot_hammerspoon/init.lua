-- toggle Alacritty opacity
hs.hotkey.bind({ "cmd" }, "u", function()
  hs.execute("toggle_opacity", true)
end)

-- ====================== APP TOGGLER ======================
-- Option + <key> toggles an app: launch it if not running, hide it if it is
-- already frontmost, otherwise bring it to focus.
--
-- The previous implementation pulled the app's window onto the *current* Space
-- via hs.spaces.moveWindowToSpace(). That call uses a private SkyLight API
-- (driving Mission Control through the Dock) which broke in macOS 15 and can
-- wedge WindowServer on macOS 26, freezing all Space switching until a
-- WindowServer restart. It is removed here: the focus branch now uses the
-- public app:activate(true), which switches to the Space the app lives on
-- instead of moving its window across Spaces. To keep a specific app on the
-- current desktop, set it to "All Desktops" in its Dock Options instead.

local function toggleApp(appName, launchTarget)
  local app = hs.application.find(appName)
  if app == nil then
    hs.application.launchOrFocus(launchTarget or appName)
  elseif app:isFrontmost() then
    app:hide()
  else
    app:activate(true)
  end
end

-- Terminal on option+space. To switch terminal, change the appName/target here.
hs.hotkey.bind({ "⌥" }, "space", function() toggleApp("ghostty", "Ghostty.app") end)

hs.hotkey.bind({ "⌥" }, "S", function() toggleApp("Slack", "Slack.app") end)
hs.hotkey.bind({ "⌥" }, "V", function() toggleApp("Vivaldi", "Vivaldi.app") end)
hs.hotkey.bind({ "⌥" }, "P",
  function() toggleApp("PyCharm", "/Users/ryosukematsushima/Applications/PyCharm Professional Edition.app") end)
hs.hotkey.bind({ "⌥" }, "D", function() toggleApp("DataGrip", "/Users/ryosukematsushima/Applications/DataSpell.app") end)
hs.hotkey.bind({ "⌥" }, "O", function() toggleApp("Obsidian", "Obsidian.app") end)
hs.hotkey.bind({ "⌥" }, "F", function() toggleApp("Finder", "Finder") end)
hs.hotkey.bind({ "⌥" }, "N", function() toggleApp("Notion", "Notion.app") end)
hs.hotkey.bind({ "⌥" }, "C", function() toggleApp("Cursor", "Cursor.app") end)
hs.hotkey.bind({ "⌥" }, "I",
  function() toggleApp("IntelliJ", "/Users/ryosukematsushima/Applications/IntelliJ IDEA Ultimate.app") end)

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
      {
        title = "バッテリー設定を開く",
        fn = function()
          hs.execute('open -a "System Settings"', true)
        end
      },
      {
        title = "省エネルギーモードを有効化",
        fn = function()
          hs.execute('sudo pmset -a lowpowermode 1', true)
        end
      },
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
      {
        title = "ネットワーク設定を開く",
        fn = function()
          hs.execute('open -a "System Settings"', true)
        end
      },
      {
        title = "Wi-Fi を入れ直す",
        fn = function()
          hs.execute(
            '/usr/sbin/networksetup -setairportpower en0 off; sleep 1; /usr/sbin/networksetup -setairportpower en0 on',
            true)
        end
      },
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
