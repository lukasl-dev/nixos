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
    "fang2hou/blink-copilot",
    dependencies = { "zbirenbaum/copilot.lua" },

    event = "BufWinEnter",

    opts = {
      max_completions = 1,
    },
  },
}
