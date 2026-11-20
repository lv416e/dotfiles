-- Cmd+U used to toggle Alacritty's opacity by calling the toggle_opacity script, which
-- rewrote ~/.config/alacritty/alacritty.toml in place. Alacritty, that config and the script
-- are all gone, so the binding is removed rather than left to fail silently. Ghostty sets
-- background-opacity statically in dot_config/ghostty/config.tmpl; if a live toggle is wanted
-- there it needs a new implementation (Ghostty has no config-reload-on-write equivalent).

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
-- JetBrains IDEs are addressed by name, not by path. An absolute path was wrong
-- twice over here: it carried another machine's username (/Users/ryosukematsushima),
-- so all three bindings resolved to nothing on this machine, and it pinned a
-- JetBrains Toolbox install directory that Toolbox relocates between versions.
-- hs.application.launchOrFocus resolves a bare name through LaunchServices, which
-- needs no path and keeps working wherever Toolbox puts the app. None of these are
-- installed right now (only jetbrains-toolbox is), so the bindings are inert until
-- one is - which is the point of leaving them declared.
hs.hotkey.bind({ "⌥" }, "P", function() toggleApp("PyCharm") end)
hs.hotkey.bind({ "⌥" }, "D", function() toggleApp("DataGrip") end)
hs.hotkey.bind({ "⌥" }, "O", function() toggleApp("Obsidian", "Obsidian.app") end)
hs.hotkey.bind({ "⌥" }, "F", function() toggleApp("Finder", "Finder") end)
hs.hotkey.bind({ "⌥" }, "N", function() toggleApp("Notion", "Notion.app") end)
hs.hotkey.bind({ "⌥" }, "C", function() toggleApp("Cursor", "Cursor.app") end)
hs.hotkey.bind({ "⌥" }, "I", function() toggleApp("IntelliJ IDEA") end)

-- Conditional menubar items (battery < 20%, Wi-Fi down) are Bartender Triggers,
-- not Hammerspoon. The hs.menubar version that lived here was hidden by Bartender
-- and misbehaved: hs.wifi.currentNetwork() returns nil without Location Services
-- permission (macOS 14+ redacts the SSID), so it could flag a connected Wi-Fi as down,
-- and its `sudo pmset` menu entry could never prompt for a password.
