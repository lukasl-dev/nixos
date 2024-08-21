return {
  "lewis6991/gitsigns.nvim",

  event = "BufRead",
  cmd = "Gitsigns",

  opts = {
    current_line_blame = true,

    signs = {
      add = { text = "" },
      change = { text = "" },
      delete = { text = "" },
      topdelete = { text = "" },
      changedelete = { text = "" },
      untracked = { text = "" },
    },
    signs_staged = {
      add = { text = "" },
      change = { text = "" },
      delete = { text = "" },
      topdelete = { text = "" },
      changedelete = { text = "" },
      untracked = { text = "" },
    },
  },
}
