return {
  "catppuccin/nvim",
  name = "catppuccin",

  priority = 1000,

  opts = {
    flavour = "mocha",
    integrations = {
      blink_cmp = true,
      gitsigns = true,
      treesitter = true,
      harpoon = true,
      lsp_trouble = true,
      leap = true,
      fidget = true,
      diffview = true,
    },
  },
}
