local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

-- html/cssls/jsonls/tailwindcss ship via vscode-langservers-extracted and
-- @tailwindcss/language-server; intelephense ships via the intelephense npm
-- package. All installed by modules/nvim/setup.sh.
local servers = { "html", "cssls", "tailwindcss", "jsonls", "intelephense" }

vim.lsp.config("*", {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
})

vim.lsp.enable(servers)
