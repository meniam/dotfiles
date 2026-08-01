require("full-border"):setup()
require("duckdb"):setup()
require("eza-preview"):setup({})
require("zoxide"):setup({
	update_db = true,
})
-- Restores the tab session saved to ~/.local/state/yazi/session.json
require("autosave"):setup()
