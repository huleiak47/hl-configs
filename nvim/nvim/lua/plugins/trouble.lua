return {
  "folke/trouble.nvim",
  optional = true,
  keys = {
    {
      "<leader>cs",
      "<cmd>Trouble symbols toggle win.size=50 win.position=right focus=false <cr>",
      desc = "Symbols (Trouble)",
    },
    {
      "<leader>cS",
      "<cmd>Trouble lsp toggle win.size=60 win.position=right focus=false <cr>",
      desc = "Symbols definitions / references ... (Trouble)",
    },
    {
      "<leader>ce",
      "<cmd>Trouble lsp_references toggle win.size=20 win.position=bottom focus=true <cr>",
      desc = "Symbols references (Trouble)",
    },
  },
}
