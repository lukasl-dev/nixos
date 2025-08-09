return {
  "Julian/lean.nvim",
  event = { "BufReadPre *.lean", "BufNewFile *.lean" },

  dependencies = {
    "neovim/nvim-lspconfig",
    "nvim-lua/plenary.nvim",
    "Saghen/blink.cmp",
    "nvim-telescope/telescope.nvim",
  },

  ---@type lean.Config
  opts = { -- see below for full configuration options
    mappings = true,
  },
}
