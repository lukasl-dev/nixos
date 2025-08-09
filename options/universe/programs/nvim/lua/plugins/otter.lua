return {
  "jmbuhr/otter.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    strip_wrapping_quote_characters = { "''", "'", '"', "`" },
  },
  setup = function(_, opts)
    require("otter").setup(opts)

    require("otter").activate({ "bash", "sql" }, true, true, nil)
  end,
}
