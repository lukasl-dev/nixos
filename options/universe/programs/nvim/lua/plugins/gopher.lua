return {
  "olexsmir/gopher.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },

  event = { "CmdlineEnter" },
  ft = { "go", "gomod" },

  config = function()
    require("gopher").setup()
  end,
}
