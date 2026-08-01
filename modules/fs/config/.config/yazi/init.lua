require("full-border"):setup()
require("duckdb"):setup()
require("eza-preview"):setup({})
require("zoxide"):setup({
	update_db = true,
})
-- Restores the tab session saved to ~/.local/state/yazi/session.json
require("autosave"):setup()
-- open_multi keeps <Enter> opening the whole selection, which is what the
-- default `open` command does; without it only the hovered file is opened.
require("smart-enter"):setup({ open_multi = true })
