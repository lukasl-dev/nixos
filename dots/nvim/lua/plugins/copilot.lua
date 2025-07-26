return {
  {
    "zbirenbaum/copilot.lua",

    cmd = "Copilot",
    event = "InsertEnter",

    opts = {
      suggestion = { enabled = true, auto_trigger = true },
      panel = { enabled = false },
    },
  },
}
