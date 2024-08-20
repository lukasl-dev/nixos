return {
  "catppuccin/nvim",
  name = "catppuccin",

  priority = 1000,

  --@module "catppuccin"
  ---@return catppuccin.ConfigSchemu
  opts = {
    flavour = "mocha",
    integrations = {
      cmp = true,
      gitsigns = true,
      treesitter = true,
      harpoon = true,
      lsp_trouble = true,
    },
  },
}
