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
local centered = {0.09, 0.1, 0.83, 0.8}

local layouts = {
  ["Arc"] = {0, 0, 0.5, 1},
  ["ChatGPT"] = {0.3, 0.1, 0.4, 0.8},
  ["Telegram"] = centered,
  ["WezTerm"] = centered,
  ["kitty"] = centered,
  ["Code"] = centered,
  ["Cursor"] = centered,
  ["Docker"] = centered,
  ["Docker Desktop"] = centered,
  ["Zoom Workplace"] = centered,
  ["Google Chrome"] = centered,
  ["Finder"] = centered,
  ["Photos"] = centered,
  ["Snagit"] = centered,
  ["Sublime Text"] = centered,
  ["App Store"] = centered,
  ["PhpStorm"] = "maximize",
}

local function apply(win, unit)
  if unit == "maximize" then
    win:maximize()
  else
    win:moveToUnit(unit)
  end
end

-- Electron apps take seconds to open their first window, so keep asking for it,
-- then apply the layout once more because they restore their own saved frame.
local function place(app, unit, attempt)
  attempt = attempt or 1

  local win = app:mainWindow()
  if win and win:isStandard() then
    apply(win, unit)
    hs.timer.doAfter(1.5, function()
      if win:isVisible() then
        apply(win, unit)
      end
    end)
    return
  end

  if app:isRunning() and attempt < 20 then
    hs.timer.doAfter(0.5, function()
      place(app, unit, attempt + 1)
    end)
  end
end

app_watcher = hs.application.watcher.new(function(app_name, event_type, app)
  if event_type ~= hs.application.watcher.launched then
    return
  end

  local unit = layouts[app_name]
  if unit then
    place(app, unit)
  end
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
