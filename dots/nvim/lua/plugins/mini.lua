return {
  "echasnovski/mini.nvim",

  event = "VeryLazy",

  config = function()
    -- require("mini.ai").setup()
    require("mini.surround").setup()
  end,
}
