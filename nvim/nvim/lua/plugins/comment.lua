return {
  "nvim-mini/mini.comment",
  opts = {
    -- 覆盖/追加注释符号
    options = {
      custom_commentstring = function()
        -- 只对 C 文件生效
        if vim.bo.filetype == "c" then
          return "// %s"
        end
        -- 其他文件类型保持默认
        return nil
      end,
    },
  },
}
