return {
  "nvim-java/nvim-java",

  enabled = false,
  enable = false,

  -- event = "VeryLazy",

  config = function()
    require("java").setup()
    require("lspconfig").jdtls.setup {}
  end,
}
