return {
  "stevearc/conform.nvim",
  opts = {
    -- 定义新 formatter
    formatters = {
      mdformat = {
        command = "cmd", -- 系统 PATH 中的可执行程序名
        args = { "/c", "mdformat" }, -- 格式化参数 (可选)
        stdin = true, -- 是否使用标准输入 (按工具要求)
      },
      pumlformat = {
        command = "pumlformat",
        stdin = true,
      },
    },
    -- 为文件类型指定格式化程序
    formatters_by_ft = {
      markdown = { "mdformat" },
      plantuml = { "pumlformat" },
    },
  },
}
