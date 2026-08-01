require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- gitsigns
map("n", "]c", function() require("gitsigns").nav_hunk("next") end, { desc = "gitsigns next hunk" })
map("n", "[c", function() require("gitsigns").nav_hunk("prev") end, { desc = "gitsigns prev hunk" })
map("n", "<leader>hs", function() require("gitsigns").stage_hunk() end, { desc = "gitsigns stage hunk" })
map("n", "<leader>hr", function() require("gitsigns").reset_hunk() end, { desc = "gitsigns reset hunk" })
map("n", "<leader>hp", function() require("gitsigns").preview_hunk() end, { desc = "gitsigns preview hunk" })
map("n", "<leader>hb", function() require("gitsigns").blame_line({ full = true }) end, { desc = "gitsigns blame line" })
