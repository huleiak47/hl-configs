-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- use ctrl-c to copy text to system clipboard in visual mode
map("x", "<C-c>", '"*y', { desc = "Copy to system clipboard", remap = true })
