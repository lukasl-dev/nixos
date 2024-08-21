return {
  "lewis6991/gitsigns.nvim",

  event = "BufRead",
  cmd = "Gitsigns",

  opts = {
    signs = {
      add = { text = "" },
      change = { text = "" },
      delete = { text = "󰍵" },
      changedelete = { text = "󱕖" },
      untracked = { text = "" },
    },
    signs_staged = {
      add = { text = "" },
      change = { text = "" },
      delete = { text = "󰍵" },
      changedelete = { text = "󱕖" },
      untracked = { text = "" },
    },
  },
}
