-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

opt.cindent = true
opt.smartindent = true
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.smarttab = true
opt.autoindent = true
opt.colorcolumn = "81,121"
opt.ignorecase = true
opt.smartcase = true
opt.relativenumber = false
opt.number = true
opt.selection = "old"
opt.textwidth = 0
opt.title = true
opt.clipboard = ""
opt.wrap = true
opt.formatoptions = "roqnlmM1j"
opt.fileformats = "unix,dos"
opt.spell = false

if vim.fn.has("wsl") then
  -- win32yank.exe will be run
  vim.g.clipboard = "win32yank"
end
