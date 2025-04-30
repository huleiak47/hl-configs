-- 使用 tab 选择建议
return {
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require("cmp")
      -- 覆盖默认按键映射
      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.confirm({ select = true }) -- 选择第一个备选项
          else
            fallback() -- 保留默认 Tab 行为
          end
        end, { "i", "s" }),
        ["<CR>"] = cmp.mapping.abort(), -- （可选）禁用 Enter 键确认
      })
      return opts
    end,
  },
}
