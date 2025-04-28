return {
  "nvim-java/nvim-java",

  event = "VeryLazy",

  config = function()
    require("java").setup()
    require("lspconfig").jdtls.setup {}
  end,
}
