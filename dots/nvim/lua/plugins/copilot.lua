return {
  {
    "zbirenbaum/copilot.lua",

    cmd = "Copilot",
    event = "InsertEnter",

    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
    },
  },

  {
    "giuxtaposition/blink-cmp-copilot",
    dependencies = { "zbirenbaum/copilot.lua" },

    event = "BufWinEnter",
  },
}
