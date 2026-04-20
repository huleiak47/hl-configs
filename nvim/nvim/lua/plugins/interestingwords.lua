return {
  "Mr-LLLLL/interestingwords.nvim",
  config = function()
    require("interestingwords").setup({
      colors = {
        "#308030",
        "#106010",
        "#a02020",
        "#80c020",
        "#5050e0",
        "#6020c0",
        "#c09030",
        "#a07020",
        "#a03c7b",
        "#802c5b",
        "#207070",
        "#205090",
      },
      search_count = true,
      navigation = true,
      scroll_center = true,
      search_key = "<leader>mm",
      cancel_search_key = "<leader>mM",
      color_key = "<leader>mk",
      cancel_color_key = "<leader>mK",
      select_mode = "random", -- random or loop
    })
  end,
}
