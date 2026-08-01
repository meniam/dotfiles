require("full-border"):setup()
require("duckdb"):setup()
require("eza-preview"):setup({})
require("zoxide"):setup({
	update_db = true,
})

-- Restores the tab session saved to ~/.local/state/yazi/session.json, then
-- points the active tab back at the directory Yazi was actually launched
-- in. autosave's restore otherwise leaves the active tab on whatever cwd
-- was saved last, ignoring the directory Yazi started in. `ya.sync` needs
-- a real plugin's job context, so the launch dir is read via `PWD` instead.
require("autosave"):setup()
local launch_cwd = os.getenv("PWD")
if launch_cwd then
	ya.emit("cd", { launch_cwd })
end

-- open_multi keeps <Enter> opening the whole selection, which is what the
-- default `open` command does; without it only the hovered file is opened.
require("smart-enter"):setup({ open_multi = true })
