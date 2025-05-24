return {
  "stevearc/conform.nvim",
  opts = {
    -- 定义新 formatter
    formatters = {
      mdformat = {
        command = "mdformat", -- 系统 PATH 中的可执行程序名
        args = {}, -- 不要删除
        stdin = true, -- 是否使用标准输入 (按工具要求)
      },
      pumlformat = {
        command = "pumlformat",
        args = {},
        stdin = true,
      },
      -- install cmakelang by pip or Mason
      cmakeformat = {
        command = vim.fn.stdpath("config") .. "/scripts/cmake-format-wrap",
        args = {},
        stdin = true,
      },
    },
    -- 为文件类型指定格式化程序
    formatters_by_ft = {
      markdown = { "mdformat" },
      plantuml = { "pumlformat" },
      cmake = { "cmakeformat" },
    },
  },
}
