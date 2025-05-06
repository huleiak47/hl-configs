-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- use ctrl-c to copy text to system clipboard in visual mode
map("x", "<C-c>", '"*y', { desc = "Copy to system clipboard", remap = true })
map("n", "Y", "Vy", { desc = "Yank the whole line when press Y in normal mode", remap = true })

map("n", "<leader>-", ":Oil<CR>", { desc = "Open oil.nvim buffer", remap = true })

-- git
map("n", "<leader>gd", ":DiffviewOpen<CR>", { desc = "DiffviewOpen, show code diffs", remap = true })
map("n", "<leader>gh", ":DiffviewFileHistory<CR>", { desc = "show all files git history", remap = true })
map("x", "<leader>gh", ":'<,'>DiffviewFileHistory<CR>", { desc = "show selected history", remap = true })
map(
  "n",
  "<leader>g%",
  "<Cmd>DiffviewFileHistory %<CR>",
  { desc = "DiffviewFileHistory, show current history", remap = false }
)
map("n", "<leader>gn", ":Neogit<CR>", { desc = "show neogit", remap = true })
