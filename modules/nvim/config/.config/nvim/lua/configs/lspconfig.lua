local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"

-- html/cssls/jsonls/tailwindcss ship via vscode-langservers-extracted and
-- @tailwindcss/language-server, both installed by modules/nvim/setup.sh.
local servers = { "html", "cssls", "tailwindcss", "jsonls" }

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  }
end
