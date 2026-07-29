local wezterm = require("wezterm")
local mux = wezterm.mux
local config = wezterm.config_builder()

local SCROLLBACK_FZF = os.getenv("WEZTERM_SCROLLBACK_FZF") or "fzf"
local CACHE_DIR = os.getenv("HOME") .. "/.cache/wezterm/"
local SIZE_CACHE = CACHE_DIR .. "window_size_cache.txt"

wezterm.on("gui-startup", function()
  os.execute("mkdir -p " .. CACHE_DIR)
  local f = io.open(SIZE_CACHE, "r")
  if f then
    local _, _, w, h = string.find(f:read(), "(%d+),(%d+)")
    f:close()
    mux.spawn_window({ width = tonumber(w), height = tonumber(h) })
  else
    mux.spawn_window({})
  end
end)

wezterm.on("window-resized", function(_, pane)
  local tab_size = pane:tab():get_size()
  local contents = string.format("%d,%d", tab_size.cols, tab_size.rows + 2)
  local f = io.open(SIZE_CACHE, "w")
  if f then
    f:write(contents)
    f:close()
  end
end)

local function scrollback_fzf(_, pane)
  local dims = pane:get_dimensions()
  local ok_text, text = pcall(function()
    return pane:get_lines_as_escapes(dims.scrollback_rows)
  end)
  if not ok_text or text == nil then
    wezterm.log_error("scrollback_fzf: get_lines_as_escapes failed")
    return
  end
  local tmp = os.tmpname()
  local f, open_err = io.open(tmp, "w")
  if not f then
    wezterm.log_error("scrollback_fzf: " .. tostring(open_err))
    return
  end
  f:write(text)
  f:close()

  -- GUI-launched WezTerm inherits launchd's minimal PATH, which excludes Homebrew;
  -- prepend it so fzf resolves even when the pane's shell profile isn't sourced.
  local cmd =
    string.format('export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"; cat %q | %q; rm -f %q', tmp, SCROLLBACK_FZF, tmp)
  local ok_split, split_err = pcall(function()
    pane:split({
      direction = "Right",
      top_level = true,
      size = 0.65,
      args = { "/bin/bash", "-c", cmd },
    })
  end)
  if not ok_split then
    wezterm.log_error("scrollback_fzf: " .. tostring(split_err))
  end
end

-- Copy terminal selections normally; otherwise ask ZLE to copy its active region.
local function copy_terminal_or_zle_selection(window, pane)
  if window:get_selection_text_for_pane(pane) ~= "" then
    window:perform_action(wezterm.action.CopyTo("Clipboard"), pane)
  else
    window:perform_action(wezterm.action.SendString("\x1b[99~"), pane)
  end
end

local TAB_BG = "rgba(20, 25, 30, 0.85)"
local ACTIVE_BG = "#cba6f7"
local ACTIVE_FG = "#1e1e2e"
local INACTIVE_FG = "#676767"

wezterm.on("format-tab-title", function(tab, _, _, _, hover)
  local title = tab.active_pane.title
  if #title > 22 then title = title:sub(1, 22) .. "…" end
  title = " " .. (tab.tab_index + 1) .. ": " .. title .. " "

  if tab.is_active then
    local cells = {}
    if tab.tab_index > 0 then
      table.insert(cells, { Background = { Color = TAB_BG } })
      table.insert(cells, { Foreground = { Color = ACTIVE_BG } })
      table.insert(cells, { Text = utf8.char(0xe0b6) })
    end
    table.insert(cells, { Background = { Color = ACTIVE_BG } })
    table.insert(cells, { Foreground = { Color = ACTIVE_FG } })
    table.insert(cells, { Attribute = { Intensity = "Bold" } })
    table.insert(cells, { Text = title })
    table.insert(cells, { Background = { Color = TAB_BG } })
    table.insert(cells, { Foreground = { Color = ACTIVE_BG } })
    table.insert(cells, { Text = utf8.char(0xe0b4) })
    return cells
  end

  return {
    { Background = { Color = TAB_BG } },
    { Foreground = { Color = hover and "#c7c7c7" or INACTIVE_FG } },
    { Text = title },
  }
end)

-- Send Option as a plain Alt modifier instead of composing accented characters,
-- so ctrl+alt+<key> chords reach terminal apps (e.g. herdr) as real modifier combos.
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

-- Font (matches Kitty)
config.font = wezterm.font("FiraCode Nerd Font Mono")
config.font_size = 15.0
config.line_height = 1.2
config.harfbuzz_features = { "zero" }

-- Color palette (ported from Kitty)
config.colors = {
  foreground = "#c7c7c7",
  background = "#14191e",

  cursor_bg = "#fefffe",
  cursor_fg = "#000000",

  selection_bg = "#ffdd2d",
  selection_fg = "rgba(0, 0, 0, 0.8)",

  ansi = {
    "#14191e", -- black
    "#c91b00", -- red
    "#00c200", -- green
    "#c7c400", -- yellow
    "#2540b7", -- blue
    "#c930c7", -- magenta
    "#00c5c7", -- cyan
    "#c7c7c7", -- white
  },
  brights = {
    "#676767", -- bright black
    "#ff6e67", -- bright red
    "#57e690", -- bright green
    "#fefb67", -- bright yellow
    "#6871ff", -- bright blue
    "#ff76ff", -- bright magenta
    "#5ffdff", -- bright cyan
    "#feffff", -- bright white
  },

  tab_bar = {
    background = "rgba(20, 25, 30, 0.85)",
    inactive_tab_edge = "rgba(20, 25, 30, 0.85)",
    active_tab = {
      bg_color = "#cba6f7",
      fg_color = "#1e1e2e",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "rgba(20, 25, 30, 0.85)",
      fg_color = "#676767",
    },
    inactive_tab_hover = {
      bg_color = "rgba(30, 40, 50, 0.85)",
      fg_color = "#c7c7c7",
    },
    new_tab = {
      bg_color = "rgba(20, 25, 30, 0.85)",
      fg_color = "#676767",
    },
    new_tab_hover = {
      bg_color = "rgba(30, 40, 50, 0.85)",
      fg_color = "#c7c7c7",
    },
  },
}

-- Window
config.adjust_window_size_when_changing_font_size = false
config.window_background_opacity = 0.85
if wezterm.target_triple:find("apple") then
  config.window_decorations = "RESIZE | MACOS_FORCE_DISABLE_SHADOW"
  config.macos_window_background_blur = 30
else
  config.window_decorations = "RESIZE"
end
config.window_padding = {
  left = 12,
  right = 12,
  top = 12,
  bottom = 12,
}

-- Tabs
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = false
config.use_fancy_tab_bar = false
config.tab_max_width = 25

-- Cursor
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

-- Performance
config.front_end = "WebGpu"
config.max_fps = 120
config.animation_fps = 60

-- Behavior
config.scrollback_lines = 10000
config.audible_bell = "Disabled"
config.automatically_reload_config = true
config.window_close_confirmation = "NeverPrompt"

-- Launch menu (SSH shortcuts)
config.launch_menu = {
  { label = "ssh: s", args = { "ssh", "s" } },
  { label = "ssh: router", args = { "ssh", "router" } },
  { label = "ssh: db-server", args = { "ssh", "db-server" } },
}

-- Key bindings
config.keys = {
  { key = "d", mods = "CMD", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "d", mods = "CMD|SHIFT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "w", mods = "CMD", action = wezterm.action.CloseCurrentPane({ confirm = false }) },
  { key = "phys:w", mods = "CMD", action = wezterm.action.CloseCurrentPane({ confirm = false }) },
  { key = "t", mods = "CMD", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
  { key = "y", mods = "CMD", action = wezterm.action.SpawnCommandInNewTab({ args = { "yazi" } }) },
  {
    key = "t",
    mods = "CMD|SHIFT",
    action = wezterm.action_callback(function()
      local ok, reason, code = os.execute(
        'export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"; herdr tab create --focus >>/tmp/herdr-hotkey.log 2>&1'
      )
      if not ok then
        wezterm.log_error("herdr tab create failed: " .. tostring(reason) .. " " .. tostring(code))
      end
    end),
  },
  { key = "f", mods = "CMD", action = wezterm.action.Search("CurrentSelectionOrEmptyString") },
  {
    key = "f",
    mods = "CTRL|SHIFT",
    action = wezterm.action_callback(scrollback_fzf),
  },
  {
    key = "phys:f",
    mods = "CTRL|SHIFT",
    action = wezterm.action_callback(scrollback_fzf),
  },
  { key = "k", mods = "CMD", action = wezterm.action.ClearScrollback("ScrollbackAndViewport") },
  { key = "c", mods = "CMD", action = wezterm.action_callback(copy_terminal_or_zle_selection) },

  -- Pane navigation
  { key = "h", mods = "CMD|SHIFT", action = wezterm.action.ActivatePaneDirection("Left") },
  { key = "l", mods = "CMD|SHIFT", action = wezterm.action.ActivatePaneDirection("Right") },
  { key = "k", mods = "CMD|SHIFT", action = wezterm.action.ActivatePaneDirection("Up") },
  { key = "j", mods = "CMD|SHIFT", action = wezterm.action.ActivatePaneDirection("Down") },

  -- Pane resizing
  { key = "LeftArrow", mods = "CMD|ALT", action = wezterm.action.AdjustPaneSize({ "Left", 3 }) },
  { key = "RightArrow", mods = "CMD|ALT", action = wezterm.action.AdjustPaneSize({ "Right", 3 }) },
  { key = "UpArrow", mods = "CMD|ALT", action = wezterm.action.AdjustPaneSize({ "Up", 3 }) },
  { key = "DownArrow", mods = "CMD|ALT", action = wezterm.action.AdjustPaneSize({ "Down", 3 }) },

  -- Switch tabs with arrow keys
  { key = "LeftArrow", mods = "CMD", action = wezterm.action.ActivateTabRelative(-1) },
  { key = "RightArrow", mods = "CMD", action = wezterm.action.ActivateTabRelative(1) },

  -- Word selection (macOS-style: Option+Shift extends selection by word)
  { key = "LeftArrow", mods = "OPT|SHIFT", action = wezterm.action.SendString("\x1b[1;4D") },
  { key = "RightArrow", mods = "OPT|SHIFT", action = wezterm.action.SendString("\x1b[1;4C") },

  -- Start / end of line selection (CMD+SHIFT extends selection to line start/end)
  { key = "LeftArrow", mods = "CMD|SHIFT", action = wezterm.action.SendString("\x1b[97;6u") },
  { key = "RightArrow", mods = "CMD|SHIFT", action = wezterm.action.SendString("\x1b[101;6u") },
  { key = "LeftArrow", mods = "CTRL|SHIFT", action = wezterm.action.SendString("\x1b[97;6u") },
  { key = "RightArrow", mods = "CTRL|SHIFT", action = wezterm.action.SendString("\x1b[101;6u") },

  -- Word navigation
  { key = "LeftArrow", mods = "OPT", action = wezterm.action.SendString("\x1bb") },
  { key = "RightArrow", mods = "OPT", action = wezterm.action.SendString("\x1bf") },
  { key = "LeftArrow", mods = "CTRL", action = wezterm.action.SendString("\x1bb") },
  { key = "RightArrow", mods = "CTRL", action = wezterm.action.SendString("\x1bf") },

  -- Character selection
  { key = "LeftArrow", mods = "SHIFT", action = wezterm.action.SendString("\x1b[1;2D") },
  { key = "RightArrow", mods = "SHIFT", action = wezterm.action.SendString("\x1b[1;2C") },

  -- Switch tabs by number
  { key = "1", mods = "CMD", action = wezterm.action.ActivateTab(0) },
  { key = "2", mods = "CMD", action = wezterm.action.ActivateTab(1) },
  { key = "3", mods = "CMD", action = wezterm.action.ActivateTab(2) },
  { key = "4", mods = "CMD", action = wezterm.action.ActivateTab(3) },
  { key = "5", mods = "CMD", action = wezterm.action.ActivateTab(4) },
  { key = "6", mods = "CMD", action = wezterm.action.ActivateTab(5) },
  { key = "7", mods = "CMD", action = wezterm.action.ActivateTab(6) },
  { key = "8", mods = "CMD", action = wezterm.action.ActivateTab(7) },
  { key = "9", mods = "CMD", action = wezterm.action.ActivateTab(-1) },

  -- Toggle current pane zoom
  { key = "z", mods = "CTRL|SHIFT", action = wezterm.action.TogglePaneZoomState },

  -- Quick select
  { key = "Space", mods = "CTRL", action = wezterm.action.QuickSelect },

  -- Launch menu (SSH shortcuts)
  { key = "o", mods = "CMD|SHIFT", action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|LAUNCH_MENU_ITEMS" }) },
}

-- Quick-select links and paths
config.quick_select_patterns = {
  "[\\w\\-/.]+\\.[\\w]+:\\d+",
}

return config
