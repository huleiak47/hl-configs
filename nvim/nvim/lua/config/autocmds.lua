-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- vim.g.im_mode_insert = "1033"
--
-- local function store_im_and_switch_english()
--   local current_im = vim.fn.system("im-select.exe")
--   vim.g.im_mode_insert = current_im -- 保存当前输入法标识
--   -- vim.notify("switch to 1033, old im: " .. current_im, vim.log.levels.DEBUG)
--   pcall(os.execute, "im-select.exe 1033") -- 强制切换回英文
-- end
--
-- vim.api.nvim_create_autocmd("InsertLeave", {
--   pattern = "*",
--   callback = store_im_and_switch_english,
-- })
--
-- vim.api.nvim_create_autocmd("InsertEnter", {
--   pattern = "*",
--   callback = function()
--     -- vim.notify("switch to im: " .. vim.g.im_mode_insert, vim.log.levels.DEBUG)
--     pcall(os.execute, "im-select.exe " .. vim.g.im_mode_insert)
--   end,
-- })

vim.api.nvim_create_autocmd("InsertEnter", {
  pattern = "*",
  callback = function()
    vim.opt_local.relativenumber = false
  end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*",
  callback = function()
    vim.opt_local.relativenumber = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "json", "yaml", "lua", "jsonc" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

vim.api.nvim_create_autocmd({ "BufReadPost" }, {
  group = vim.api.nvim_create_augroup("AutoProjectRoot", { clear = true }),
  callback = function()
    -- 排除临时缓冲区和无文件路径的情况
    local file_path = vim.fn.expand("%:p")
    if file_path == "" or vim.bo.buftype ~= "" then
      return
    end
    -- 调用 ProjectRoot 并错误处理
    local status, _ = pcall(vim.cmd.ProjectRoot)
    if not status then
      -- vim.notify("ProjectRoot command failed", vim.log.levels.WARN)
    end
  end,
})
