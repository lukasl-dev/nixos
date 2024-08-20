return {
  "nvimdev/lspsaga.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },

  event = "LspAttach",

  opts = {
    symbol_in_winbar = {
      enable = false,
    },
    lightbulb = {
      enable = false,
    },
  },
}
