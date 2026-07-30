local mash = {"ctrl", "alt", "cmd"}

-- Move the focused window to the left half of the screen.
hs.hotkey.bind(mash, "Left", function()
  local win = hs.window.focusedWindow()
  win:moveToUnit({0, 0, 0.5, 1})
end)

-- Move the focused window to the right half of the screen.
hs.hotkey.bind(mash, "Right", function()
  local win = hs.window.focusedWindow()
  win:moveToUnit({0.5, 0, 0.5, 1})
end)

-- Maximize the focused window in its current screen.
hs.hotkey.bind(mash, "Up", function()
  local win = hs.window.focusedWindow()
  win:maximize()
end)

-- Center the focused window with margins around it.
hs.hotkey.bind(mash, "Down", function()
  local win = hs.window.focusedWindow()
  win:moveToUnit({0.09, 0.1, 0.83, 0.8})
end)

-- Position selected applications after their main window becomes available.
app_watcher = hs.application.watcher.new(function(app_name, event_type, app)
  if event_type ~= hs.application.watcher.launched then
    return
  end

  hs.timer.doAfter(0.8, function()
    local win = app:mainWindow()
    if not win then
      return
    end

    if app_name == "Arc" then
      win:moveToUnit({0, 0, 0.5, 1})
    elseif app_name == "Telegram" then
      -- win:setFrame(hs.geometry.rect(1400, 80, 420, 900))
      win:moveToUnit({0.09, 0.1, 0.83, 0.8})
    elseif app_name == "WezTerm" then
      win:moveToUnit({0.09, 0.1, 0.83, 0.8})
    elseif app_name == "Code" then
      win:moveToUnit({0.09, 0.1, 0.83, 0.8})
    elseif app_name == "Docker" then
      win:moveToUnit({0.09, 0.1, 0.83, 0.8})
    elseif app_name == "Docker Desktop" then
      win:moveToUnit({0.09, 0.1, 0.83, 0.8})
    elseif app_name == "ChatGPT" then
      win:moveToUnit({0.3, 0.1, 0.4, 0.8})
    elseif app_name == "Zoom Workplace" then
      win:moveToUnit({0.09, 0.1, 0.83, 0.8})
    elseif app_name == "PhpStorm" then
      win:maximize()
    end
  end)
end)

app_watcher:start()

-- Switch to the English input source whenever WezTerm receives focus.
-- Keep the watcher in a global variable so Hammerspoon does not discard it.
local wezterm_bundle_id = "com.github.wez.wezterm"
local english_source_id = "com.apple.keylayout.US"

wezterm_input_source_watcher = hs.application.watcher.new(function(_, event_type, app)
  if event_type == hs.application.watcher.activated
      and app
      and app:bundleID() == wezterm_bundle_id then
    hs.keycodes.currentSourceID(english_source_id)
  end
end)

wezterm_input_source_watcher:start()
