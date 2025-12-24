return {
  "TimUntersberger/neogit",
  cmd = "Neogit",
  config = function()
    require("neogit").setup({
      kind = "floating", -- opens neogit in a floating window
      signs = {
        -- { CLOSED, OPENED }
        section = { "", "" },
        item = { "", "" },
        hunk = { "", "" },
      },
      integrations = { diffview = true }, -- adds integration with diffview.nvim
    })
  end,
}
