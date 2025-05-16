-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- use ctrl-c to copy text to system clipboard in visual mode
map("x", "<C-c>", '"+y', { desc = "Copy to system clipboard", remap = false })
map("n", "Y", "Vy", { desc = "Yank the whole line when press Y in normal mode", remap = false })

map("n", "<leader>-", ":Oil<CR>", { desc = "Open oil.nvim buffer", remap = false })

-- git
map("n", "<leader>gd", ":DiffviewOpen<CR>", { desc = "DiffviewOpen, show code diffs", remap = false })
map("n", "<leader>gh", ":DiffviewFileHistory<CR>", { desc = "show all files git history", remap = false })
map("x", "<leader>gh", ":'<,'>DiffviewFileHistory<CR>", { desc = "show selected history", remap = false })
map(
  "n",
  "<leader>g%",
  "<Cmd>DiffviewFileHistory %<CR>",
  { desc = "DiffviewFileHistory, show current history", remap = false }
)
map("n", "<leader>gn", ":Neogit<CR>", { desc = "show neogit", remap = false })

-- use c-/ to toggle comment
map("n", "<C-/>", "gcc", { desc = "toggle comment for current line", remap = true })
map("x", "<C-/>", "gc", { desc = "toggle comment for selected lines", remap = true })
-- in terminal C-/ will be remaped to C-_
map("n", "<C-_>", "gcc", { desc = "toggle comment for current line", remap = true })
map("x", "<C-_>", "gc", { desc = "toggle comment for selected lines", remap = true })

map("n", "<F4>", ":q<CR>", { desc = "close current window", remap = false })

-- paste from clipboard
map("x", "<C-v>", '"+p`]', { desc = "paste from clipboard in visual mode", remap = false })
map("i", "<C-v>", "<C-r>+", { desc = "paste from clipboard in insert mode", remap = false })
map("c", "<C-v>", "<C-r>+", { desc = "paste to command", remap = false })
