return {
  "ahmedkhalf/project.nvim",
  config = function()
    require("project_nvim").setup({
      manual_mode = false,
      detection_methods = { "lsp", "pattern" },
      patterns = { ".git", ".svn", ".hg", "Makefile", "Cargo.toml", "pyproject.toml", "*.sln", "package.json" },
      ignore_lsp = {},
      exclude_dirs = {},
      show_hidden = false,
      silent_chdir = true,
      datapath = vim.fn.stdpath("data"),
    })
  end,
}
