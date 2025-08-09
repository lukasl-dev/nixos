return {
  "echasnovski/mini.nvim",

  enabled = false,

  event = "VeryLazy",

  config = function()
    -- require("mini.ai").setup()
    require("mini.surround").setup()
  end,
}
